// ============================================================================
// 📎 ПРИЛОЖЕНИЕ А: Листинг основного модуля системы
// ============================================================================

#import "../template.typ": vkr-code, vkr-appendix

#vkr-appendix("А", "Листинг основного модуля системы")[

#vkr-code(
  caption: [Основной модуль API системы (main.py)],
  lang: "python",
  ```
from fastapi import FastAPI, UploadFile, File, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, f1_score
import pandas as pd
import numpy as np
from typing import Optional
import joblib
import os

# Создание приложения
app = FastAPI(
    title="ML Analysis System",
    description="Система автоматизированного анализа данных",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Хранилище моделей
models_storage = {}
datasets_storage = {}


@app.post("/api/upload")
async def upload_file(file: UploadFile = File(...)):
    """Загрузка файла с данными."""
    if not file.filename.endswith('.csv'):
        raise HTTPException(
            status_code=400,
            detail="Only CSV files are supported"
        )
    
    try:
        df = pd.read_csv(file.file)
        dataset_id = len(datasets_storage) + 1
        datasets_storage[dataset_id] = df
        
        return {
            "dataset_id": dataset_id,
            "filename": file.filename,
            "rows": len(df),
            "columns": list(df.columns),
            "dtypes": df.dtypes.astype(str).to_dict()
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/api/train")
async def train_model(
    dataset_id: int,
    target_column: str,
    algorithm: str = "random_forest",
    test_size: float = 0.2
):
    """Обучение модели машинного обучения."""
    if dataset_id not in datasets_storage:
        raise HTTPException(status_code=404, detail="Dataset not found")
    
    df = datasets_storage[dataset_id]
    
    if target_column not in df.columns:
        raise HTTPException(
            status_code=400,
            detail=f"Column {target_column} not found"
        )
    
    # Подготовка данных
    X = df.drop(columns=[target_column])
    y = df[target_column]
    
    # Только числовые колонки
    X = X.select_dtypes(include=[np.number])
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=42
    )
    
    # Выбор алгоритма
    if algorithm == "random_forest":
        model = RandomForestClassifier(
            n_estimators=100,
            random_state=42,
            n_jobs=-1
        )
    else:
        raise HTTPException(
            status_code=400,
            detail=f"Unknown algorithm: {algorithm}"
        )
    
    # Обучение
    model.fit(X_train, y_train)
    
    # Оценка
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    f1 = f1_score(y_test, y_pred, average='weighted')
    
    # Сохранение модели
    model_id = len(models_storage) + 1
    models_storage[model_id] = {
        "model": model,
        "features": list(X.columns),
        "target": target_column
    }
    
    return {
        "model_id": model_id,
        "algorithm": algorithm,
        "accuracy": round(accuracy, 4),
        "f1_score": round(f1, 4),
        "features_used": list(X.columns)
    }


@app.post("/api/predict")
async def predict(model_id: int, data: dict):
    """Получение предсказания модели."""
    if model_id not in models_storage:
        raise HTTPException(status_code=404, detail="Model not found")
    
    model_info = models_storage[model_id]
    model = model_info["model"]
    features = model_info["features"]
    
    try:
        # Формируем входные данные
        X = pd.DataFrame([data])[features]
        
        # Предсказание
        prediction = model.predict(X)
        probabilities = model.predict_proba(X)
        
        return {
            "prediction": prediction.tolist(),
            "probabilities": probabilities.tolist(),
            "features_used": features
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/api/health")
async def health_check():
    """Проверка работоспособности API."""
    return {
        "status": "healthy",
        "datasets_count": len(datasets_storage),
        "models_count": len(models_storage)
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
  ```.text,
)

]
