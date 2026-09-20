# Nove Céus — Simulador de Universo (Unity V1)

Esta branch contém uma reconstrução **real em Unity**, separada do antigo protótipo Godot.

## Branch
`universe-simulator-v1`

## Regra visual
A tela não usa uma arte fullscreen para fingir que é o jogo.

O que aparece no espaço é criado como elementos reais em runtime:

- planeta 3D procedural;
- oceanos, continentes, gelo e vegetação calculados pelo shader;
- camada independente de nuvens;
- atmosfera independente com rim/fresnel;
- estrela 3D emissiva e luz real;
- lua 3D;
- cinturão de asteroides formado por objetos;
- estações orbitais compostas por geometria;
- anéis de órbita com LineRenderer;
- campo de estrelas e nebulosas por partículas procedurais;
- HUD construído por componentes uGUI.

Nenhuma imagem conceitual é usada como plano de fundo.

## Já jogável

O protótipo possui:

- rotação automática do planeta;
- arrastar para girar o mundo;
- gesto de pinça / scroll para zoom;
- simulação contínua da idade planetária;
- nove eras planetárias;
- água, atmosfera, temperatura, biodiversidade, civilização, pesquisa e órbita;
- feedback visual do planeta ligado ao estado da simulação;
- luzes urbanas no lado noturno conforme a civilização cresce;
- ações: Ajustar Órbita, Modificar Clima, Introduzir Vida, Terraformar e Acelerar Tempo;
- Criar novo mundo;
- Evoluir;
- Pesquisar;
- alternar para visão ampliada do sistema;
- interface em português inspirada no concept aprovado.

## Abrir

1. Troque para a branch `universe-simulator-v1`.
2. Abra a raiz do repositório no Unity Hub.
3. Use Unity 2022.3 LTS ou deixe uma versão mais nova compatível atualizar o projeto.
4. Na primeira abertura, o script de Editor cria `Assets/Scenes/Main.unity` e configura o Android.
5. Abra a cena criada e pressione **Play**.

## Android

Configuração inicial:
- retrato;
- ARM64;
- IL2CPP;
- Android API mínima 26;
- application id: `com.noveceus.arquiteto`.

Para gerar APK será necessário ter o módulo Android Build Support instalado no Unity Hub.

## Arquivos principais

- `Assets/Scripts/NoveCeusBootstrap.cs` — constrói toda a cena visual e a interface.
- `Assets/Scripts/UniverseSimulation.cs` — estado do planeta e evolução das eras.
- `Assets/Shaders/ProceduralPlanet.shader` — superfície procedural.
- `Assets/Shaders/Clouds.shader` — nuvens procedurais.
- `Assets/Shaders/Atmosphere.shader` — atmosfera.
- `Assets/Shaders/Star.shader` — estrela.
- `Assets/Editor/NoveCeusProjectSetup.cs` — preparação automática do projeto.

## Estado desta V1

É a primeira prova técnica da nova direção. O objetivo é validar primeiro a promessa principal:

**o jogador deve enxergar um universo vivo, construído pelo jogo, e não uma imagem bonita mascarando uma interface simples.**
