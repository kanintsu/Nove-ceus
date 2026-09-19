# Nove Céus: Ciclo da Ascensão — V0.1

Vertical slice inicial de um RPG de cultivo em **Godot 4.x**, pensado desde o início para Android landscape.

## A fantasia central

Você não nasce como "classe cultivador". Você nasce como uma pessoa dentro de um mundo que já existia antes de você.

A maioria das vidas é mortal. Algumas possuem capacidade espiritual. Outras têm potencial selado. Em casos excepcionais, um mortal pode encontrar uma oportunidade capaz de reescrever seu destino.

A morte também não reinicia o universo: o calendário avança, acontecimentos são simulados e a próxima encarnação surge em um mundo um pouco diferente.

## O que existe nesta V0.1

- região 3D estilizada construída em runtime;
- Vila da Nascente;
- Cidade Qinghe murada;
- Floresta da Névoa Fria;
- Ruínas de Lianshi;
- Montanha do Véu;
- ciclo visual de iluminação/neblina;
- origem procedural de cada vida;
- 85% de chance-base de nascer sem aptidão natural para Qi;
- potencial espiritual oculto até ser testado;
- treino físico mortal;
- estudo de conhecimento mortal;
- Pedra de Afinidade em Qinghe;
- Nascente Espiritual que só desperta quem possui um caminho natural;
- Fruto da Abertura Celestial, uma oportunidade excepcional colocada no seed de demonstração;
- Tigre da Névoa, uma besta espiritual muito superior a um mortal comum;
- combate simples, corrida, stamina e dano;
- morte e reencarnação;
- passagem de anos entre vidas;
- Crônica Viva registrando mudanças do mundo e vidas anteriores;
- crescimento visual inicial da vila com o passar das décadas;
- controles de teclado e controles touch para Android.

## Controles desktop

- `WASD` / setas: mover
- `Shift`: correr
- `Espaço` ou `F`: atacar
- `E`: interagir
- `C`: abrir a Crônica

No Android há joystick virtual e botões para atacar, interagir, correr e abrir a Crônica.

## Filosofia de design

1. **Qi é universal.** Não existem classes sobrenaturais separadas do cultivo.
2. **Cultivar não é garantido.** Uma vida completa pode terminar mortal.
3. **O mundo não escala para proteger o jogador.** Áreas perigosas podem ser visitadas cedo demais.
4. **O tempo importa.** Anos passados em uma vida ou entre reencarnações pertencem ao mundo.
5. **NPCs e mortais importam.** Inteligência, estudo, família, ofícios e legado não dependem de Qi.
6. **Raridade deve continuar rara.** O seed da demo contém uma oportunidade celestial para provar o sistema; no jogo completo, eventos desse nível não serão distribuídos como loot comum.
7. **Mapas precisam ter motivo para existir.** Cada região deve oferecer pessoas, recursos, perigos, história ou oportunidades próprias.

## Estrutura

- `scripts/core/` — nascimento, destino e estado persistente do mundo;
- `scripts/player/` — personagem e progressão mortal/espiritual;
- `scripts/world/` — construção do cenário e bestas;
- `scripts/interactables/` — objetos de mundo com significado sistêmico;
- `scripts/ui/` — HUD, touch controls, crônica e reencarnação;
- `docs/` — mundo mestre e regras de design.

## Observação da V0.1

Esta é a primeira vertical slice. Ela foi propositalmente construída sem assets comerciais ou dependências externas para que a base seja auditável, leve e substituível por arte 3D definitiva mais tarde sem reescrever os sistemas centrais.
