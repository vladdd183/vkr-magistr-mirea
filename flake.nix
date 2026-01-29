{
  description = "ВКР магистра МИРЭА - Typst шаблон";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Окружение для разработки
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            typst           # Компилятор Typst
            just            # Task runner
            typstyle        # Форматирование Typst (опционально)
          ];

          # Шрифты для корректного отображения по ГОСТ
          TYPST_FONT_PATHS = pkgs.lib.makeSearchPath "" [
            "${pkgs.liberation_ttf}/share/fonts/truetype"
            "${pkgs.dejavu_fonts}/share/fonts/truetype"
            "${pkgs.noto-fonts}/share/fonts/noto"
            "${pkgs.fira-code}/share/fonts/truetype"
            "${pkgs.jetbrains-mono}/share/fonts/truetype"
          ];

          shellHook = ''
            echo "📚 ВКР магистра МИРЭА - окружение загружено"
            echo ""
            echo "Доступные команды:"
            echo "  just build  — скомпилировать PDF"
            echo "  just watch  — автообновление при изменениях"
            echo "  just run    — скомпилировать и открыть"
            echo "  just help   — справка"
          '';
        };

        # Пакет для сборки PDF
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "vkr-magistr-mirea";
          version = "1.0.0";
          src = ./.;

          buildInputs = [ pkgs.typst ];

          buildPhase = ''
            typst compile main.typ main.pdf
          '';

          installPhase = ''
            mkdir -p $out
            cp main.pdf $out/
          '';
        };
      }
    );
}
