# 📱 TikTok Live Chat - Réplica iOS (iPhone) para App de Streaming Mobile

Este repositório contém a réplica exata do **Chat de Live do TikTok no iPhone (iOS)**, pronto para ser integrado ao seu aplicativo mobile estilo Streamlabs ou utilizado como overlay de transmissão ao vivo.

---

## 🔗 Demonstração Interativa ao Vivo

Você pode testar a réplica agora mesmo no seu navegador:
👉 **[Ver Demonstração ao Vivo](https://antigravity.luch.dev/site/bcdd7905-9db9-41e9-853a-eb74e2d82a1f/a75fd94d797abd76d87c8abe/)**

O simulador inclui:
* **Mockup iPhone 16 Pro**: Dynamic Island, status bar iOS, gestos e frame.
* **Modo Overlay Streamlabs**: Visualização limpa com fundo transparente.
* **Corações Flutuantes**: Toque na tela para disparar as curtidas orgânicas do TikTok.
* **Presentes com Contador de Combo**: Bouncing animation (`x1`, `x2`, `x15`) e efeitos sonoros.
* **Câmera ao Vivo**: Permite ligar a câmera do celular/computador para ver o chat por cima do seu próprio vídeo.

---

## 🎨 O Que Torna o Chat do TikTok no iPhone Único?

Para replicar com precisão o visual do iPhone, aplicamos as seguintes especificações de design:

1. **Cápsula Translúcida Fosca (Frosted Pill)**:
   * Cor de fundo: `rgba(0, 0, 0, 0.38)` (escuro suave com transparência).
   * Desfoque de fundo (Backdrop Blur): `8px` (`backdrop-filter: blur(8px)` no iOS).
   * Raio da borda: `15px` a `16px`.
   * Espaçamento entre mensagens: `5px` a `6px`.

2. **Tipografia Apple SF Pro**:
   * **Nome do usuário**: Peso `600` (Semi-bold), cor `rgba(255, 255, 255, 0.72)` (cinza suave característico).
   * **Texto da mensagem**: Peso `400` (Regular), cor `#FFFFFF` (branco nítido para alta legibilidade sobre o vídeo).
   * Tamanho: `13.5px` com line-height `1.35`.

3. **Efeito Fade-Out no Topo (Máscara de Gradiente)**:
   * As mensagens mais antigas no topo não somem de repente; elas desaparecem gradualmente com uma máscara:
   ```css
   -webkit-mask-image: linear-gradient(to top, rgba(0,0,0,1) 75%, rgba(0,0,0,0) 100%);
   mask-image: linear-gradient(to top, rgba(0,0,0,1) 75%, rgba(0,0,0,0) 100%);
   ```

4. **Badges de Nível Coloridas**:
   * Níveis 1–9: Cinza aço (`#78909c` → `#455a64`)
   * Níveis 10–19: Azul elétrico (`#42a5f5` → `#1976d2`)
   * Níveis 20–29: Roxo TikTok (`#ab47bc` → `#7b1fa2`)
   * Níveis 30–39: Dourado / Ouro (`#ffa726` → `#f57c00`)
   * Níveis 40+: Rosa / Diamante (`#ff4081` → `#d500f9`)

---

## 📂 Arquivos dos Componentes

O projeto inclui o componente pronto em 3 frameworks populares:

| Framework | Arquivo | Descrição |
| :--- | :--- | :--- |
| **React Native (Expo / Bare)** | [`components/TikTokLiveChat.tsx`](components/TikTokLiveChat.tsx) | Componente completo com `FlatList`, badges, combos e detecção de rolagem. |
| **Flutter (Dart)** | [`components/tiktok_live_chat.dart`](components/tiktok_live_chat.dart) | Widget Flutter com `ShaderMask`, `BackdropFilter` e `ListView.separated`. |
| **SwiftUI (iOS Nativo)** | [`components/TikTokLiveChatView.swift`](components/TikTokLiveChatView.swift) | Visual nativo em SwiftUI com `.mask`, `.background(.ultraThinMaterial)` e `ScrollViewReader`. |
| **CSS Tokens / OBS** | [`components/tiktok-chat.css`](components/tiktok-chat.css) | Estilos puros prontos para Browser Source do Streamlabs OBS. |

---

## 🚀 Como Integrar no seu App Mobile

### No React Native:
```tsx
import { TikTokLiveChat } from './components/TikTokLiveChat';

// No seu layout de Live sobreposto ao componente da Câmera:
<View style={{ flex: 1 }}>
  {/* Feed da Câmera (Streamlabs) */}
  <CameraView style={StyleSheet.absoluteFill} />

  {/* Chat TikTok no canto inferior esquerdo */}
  <View style={{ position: 'absolute', bottom: 70, left: 10 }}>
    <TikTokLiveChat messages={liveMessages} />
  </View>
</View>
```

### No Flutter:
```dart
import 'components/tiktok_live_chat.dart';

Stack(
  children: [
    CameraPreview(cameraController),
    Positioned(
      bottom: 70,
      left: 10,
      child: TikTokLiveChatWidget(messages: messagesList),
    ),
  ],
)
```
