import SwiftUI

/// Modelo de mensagem do TikTok Live Chat
public struct TikTokChatMessage: Identifiable {
    public let id: String
    public let username: String
    public let message: String
    public let avatarUrl: String?
    public let level: Int?
    public let isModerator: Bool
    public let isSubscriber: Bool
    public let isJoinEvent: Bool
    public let giftCombo: Int?
    public let giftName: String?

    public init(
        id: String = UUID().uuidString,
        username: String,
        message: String,
        avatarUrl: String? = nil,
        level: Int? = nil,
        isModerator: Bool = false,
        isSubscriber: Bool = false,
        isJoinEvent: Bool = false,
        giftCombo: Int? = nil,
        giftName: String? = nil
    ) {
        self.id = id
        self.username = username
        self.message = message
        self.avatarUrl = avatarUrl
        self.level = level
        self.isModerator = isModerator
        self.isSubscriber = isSubscriber
        self.isJoinEvent = isJoinEvent
        self.giftCombo = giftCombo
        self.giftName = giftName
    }
}

/// Visual idêntico ao Chat do TikTok no iOS (iPhone)
public struct TikTokLiveChatView: View {
    public var messages: [TikTokChatMessage]

    public init(messages: [TikTokChatMessage]) {
        self.messages = messages
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(messages) { msg in
                        TikTokMessageRow(message: msg)
                            .id(msg.id)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
            .onChange(of: messages.count) { _ in
                if let lastId = messages.last?.id {
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
        }
        // Gradiente de desfoque/fade-out suave no topo do chat (efeito icônico do TikTok no iOS)
        .mask(
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.15),
                    .init(color: .black, location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .frame(maxWidth: 320, maxHeight: 280)
    }
}

struct TikTokMessageRow: View {
    let message: TikTokChatMessage

    var body: some View {
        if message.isJoinEvent {
            // Efeito quando alguém entra na LIVE
            HStack(spacing: 4) {
                Text("✨")
                    .font(.system(size: 11))
                Text(message.username)
                    .font(.system(size: 13, weight: .semibold, design: .default))
                    .foregroundColor(Color(red: 0.99, green: 0.88, blue: 0.28))
                Text("entrou na LIVE")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.35))
            )
        } else if let combo = message.giftCombo, let gift = message.giftName {
            // Evento de Presente / Gift
            HStack(spacing: 8) {
                if let avatar = message.avatarUrl {
                    AsyncImage(url: URL(string: avatar)) { image in
                        image.resizable()
                    } placeholder: {
                        Circle().fill(Color.gray.opacity(0.5))
                    }
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(message.username)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.75))
                    Text("Enviou \(gift)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                }

                Spacer()

                Text("x\(combo)")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .italic()
                    .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.2))
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 1, y: 1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0.99, green: 0.17, blue: 0.33).opacity(0.25))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color(red: 0.99, green: 0.17, blue: 0.33).opacity(0.4), lineWidth: 1)
                    )
            )
        } else {
            // Mensagem normal do chat
            HStack(alignment: .top, spacing: 6) {
                // Avatar redondo
                if let avatar = message.avatarUrl {
                    AsyncImage(url: URL(string: avatar)) { image in
                        image.resizable()
                    } placeholder: {
                        Circle().fill(Color.gray.opacity(0.6))
                    }
                    .frame(width: 22, height: 22)
                    .clipShape(Circle())
                }

                // Corpo do comentário com badges em linha
                Text(attributedString)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color.black.opacity(0.38))
            )
        }
    }

    private var attributedString: AttributedString {
        var result = AttributedString()

        // Badge de Nível (se houver)
        if let lvl = message.level {
            var lvlStr = AttributedString("★ \(lvl) ")
            lvlStr.foregroundColor = .white
            lvlStr.font = .system(size: 9.5, weight: .bold, design: .rounded)
            result.append(lvlStr)
        }

        // Nome de Usuário (estilo iOS TikTok: cinza suave 72% de opacidade)
        var userStr = AttributedString("\(message.username): ")
        userStr.foregroundColor = .white.opacity(0.72)
        userStr.font = .system(size: 13.5, weight: .semibold, design: .default)
        result.append(userStr)

        // Texto do comentário (Branco puro, nítido)
        var msgStr = AttributedString(message.message)
        msgStr.foregroundColor = .white
        msgStr.font = .system(size: 13.5, weight: .regular, design: .default)
        result.append(msgStr)

        return result
    }
}
