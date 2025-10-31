# Sobre a implementação

* O projeto está organizado em módulos. A app depende dos módulos Core, CoreCommons, CoreNetwork e FavoriteGists.
* O módulo de Core define algumas abstrações básicas que os fluxos devem seguir, com alguns utilitários em CoreCommons
* Cada fluxo está implementado dentro da pasta `Flows`
* A navegação é gerenciada por routers.
* Para persistência dos Favoritos utilizei o `UserDefaults` por questão de praticidade, sendo abstraído através de um protocolo `Storable`.
* O acesso aos dados é feito através de objetos *Repository*, e para cada repository há um protocolo definido (ex.: `GistRepository` e `ProductionGistRepository`). Isso permite que seja simples de mockar ou substituir a camada de acesso a dados.
* A funcionalidade de Favoritos trabalha com uma abstração `FavoriteItem`, de modo que seria possível utilizar ela com qualquer objeto que implemente o protocolo. Aqui eu fiz o objeto `Gist` implementar o protocolo. Considerei criar um outro tipo especificamente para os favoritos, mas resolvi fazer o mais simples.
* Ao chegar no final da lista, novos gists são carregados automaticamente
* Alguns tests unitários foram adicionados, utilizando `XCTest`
* Erros são logados com OSLog


## Dependências

* Evitei usar libs externas, a única exceção sendo SnapKit para ajustes de layout. Todos os layouts foram feitos em view code.
* As dependencias criadas para o projeto estão localizadas na pasta 'Dependencies', na raiz do projeto. Utilizei SPM para gerenciamento.
* Utilizei Combine apenas para gerenciamento de eventos. Cogitei fazer de outras maneiras, mas assim me pareceu mais prático.

# Screenshots

<img width="250" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-10-30 at 22 26 13" src="https://github.com/user-attachments/assets/e0007c07-6c0f-4e9a-bd42-bf009eca0c4d" />
<img width="250" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-10-30 at 22 26 17" src="https://github.com/user-attachments/assets/0bcb604b-284a-416d-b8d1-458038e69a5f" />
<img width="250" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-10-30 at 22 26 21" src="https://github.com/user-attachments/assets/215150c1-fec1-46eb-a1c0-dae62da1f85e" />
<img width="250" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-10-30 at 22 26 31" src="https://github.com/user-attachments/assets/08e31dd1-2863-4396-9c3c-7bdf0f440689" />
