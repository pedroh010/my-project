import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  Image,
  TouchableOpacity,
  Animated,
  Platform,
} from 'react-native';

/**
 * Tipos de Mensagens e Eventos do TikTok Live Chat
 */
export interface ChatBadge {
  type: 'level' | 'mod' | 'subscriber' | 'top_gifter';
  level?: number;
  text?: string;
}

export interface ChatMessage {
  id: string;
  type: 'comment' | 'gift' | 'join' | 'follow' | 'system';
  username: string;
  avatarUrl?: string;
  badges?: ChatBadge[];
  text?: string;
  gift?: {
    name: string;
    icon: string;
    combo: number;
  };
  timestamp: number;
}

interface TikTokLiveChatProps {
  messages: ChatMessage[];
  onPressUser?: (username: string) => void;
  maxMessages?: number;
}

export const TikTokLiveChat: React.FC<TikTokLiveChatProps> = ({
  messages,
  onPressUser,
  maxMessages = 100,
}) => {
  const flatListRef = useRef<FlatList>(null);
  const [isAtBottom, setIsAtBottom] = useState(true);
  const [unreadCount, setUnreadCount] = useState(0);

  // Manter rolagem automática para a última mensagem
  useEffect(() => {
    if (isAtBottom && messages.length > 0) {
      flatListRef.current?.scrollToEnd({ animated: true });
    } else if (!isAtBottom) {
      setUnreadCount((prev) => prev + 1);
    }
  }, [messages, isAtBottom]);

  const scrollToBottom = () => {
    flatListRef.current?.scrollToEnd({ animated: true });
    setIsAtBottom(true);
    setUnreadCount(0);
  };

  // Cores de gradiente de nível do TikTok
  const getLevelBadgeColors = (level: number = 1) => {
    if (level >= 40) return { bg: '#FE2C55', border: '#FF7B90' };
    if (level >= 30) return { bg: '#FF9800', border: '#FFB74D' };
    if (level >= 20) return { bg: '#9C27B0', border: '#BA68C8' };
    if (level >= 10) return { bg: '#2196F3', border: '#64B5F6' };
    return { bg: '#607D8B', border: '#90A4AE' };
  };

  const renderBadge = (badge: ChatBadge, index: number) => {
    if (badge.type === 'level') {
      const colors = getLevelBadgeColors(badge.level);
      return (
        <View
          key={`badge-${index}`}
          style={[styles.badgePill, { backgroundColor: colors.bg }]}
        >
          <Text style={styles.badgeIcon}>★</Text>
          <Text style={styles.badgeText}>{badge.level || 1}</Text>
        </View>
      );
    }
    if (badge.type === 'mod') {
      return (
        <View
          key={`badge-${index}`}
          style={[styles.badgePill, { backgroundColor: '#00B4D8' }]}
        >
          <Text style={styles.badgeText}>MOD</Text>
        </View>
      );
    }
    if (badge.type === 'subscriber') {
      return (
        <View
          key={`badge-${index}`}
          style={[styles.badgePill, { backgroundColor: '#FE2C55' }]}
        >
          <Text style={styles.badgeIcon}>♥</Text>
          <Text style={styles.badgeText}>SUB</Text>
        </View>
      );
    }
    return null;
  };

  const renderItem = ({ item }: { item: ChatMessage }) => {
    // 1. Mensagem de entrada na live ("fulano entrou")
    if (item.type === 'join') {
      return (
        <View style={styles.messageRow}>
          <View style={[styles.bubble, styles.joinBubble]}>
            <Text style={styles.joinText}>
              <Text style={styles.joinIcon}>✨ </Text>
              <Text style={styles.joinUsername}>{item.username}</Text> entrou na LIVE
            </Text>
          </View>
        </View>
      );
    }

    // 2. Mensagem de presente com combo ("Enviou Rosa x15")
    if (item.type === 'gift' && item.gift) {
      return (
        <View style={styles.messageRow}>
          <View style={[styles.bubble, styles.giftBubble]}>
            {item.avatarUrl ? (
              <Image source={{ uri: item.avatarUrl }} style={styles.avatar} />
            ) : (
              <View style={[styles.avatar, styles.avatarPlaceholder]}>
                <Text style={styles.avatarInitial}>{item.username[0]?.toUpperCase()}</Text>
              </View>
            )}
            <View style={styles.giftInfo}>
              <Text style={styles.usernameText}>{item.username}</Text>
              <Text style={styles.giftSubtitle}>
                Enviou {item.gift.name} <Text style={styles.giftIcon}>{item.gift.icon}</Text>
              </Text>
            </View>
            <View style={styles.comboBadge}>
              <Text style={styles.comboText}>x{item.gift.combo}</Text>
            </View>
          </View>
        </View>
      );
    }

    // 3. Comentário normal do chat
    return (
      <View style={styles.messageRow}>
        <View style={styles.bubble}>
          {item.avatarUrl ? (
            <Image source={{ uri: item.avatarUrl }} style={styles.avatar} />
          ) : (
            <View style={[styles.avatar, styles.avatarPlaceholder]}>
              <Text style={styles.avatarInitial}>{item.username[0]?.toUpperCase()}</Text>
            </View>
          )}

          <View style={styles.commentContent}>
            {/* Badges do Usuário */}
            {item.badges && item.badges.length > 0 && (
              <View style={styles.badgesRow}>
                {item.badges.map(renderBadge)}
              </View>
            )}

            <Text style={styles.textContainer}>
              <Text
                style={styles.usernameText}
                onPress={() => onPressUser?.(item.username)}
              >
                {item.username}{' '}
              </Text>
              <Text style={styles.commentText}>{item.text}</Text>
            </Text>
          </View>
        </View>
      </View>
    );
  };

  return (
    <View style={styles.container}>
      {/* Lista de mensagens com rolagem e estilo TikTok iPhone */}
      <FlatList
        ref={flatListRef}
        data={messages.slice(-maxMessages)}
        keyExtractor={(item) => item.id}
        renderItem={renderItem}
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.listContent}
        onScroll={(e) => {
          const { layoutMeasurement, contentOffset, contentSize } = e.nativeEvent;
          const isCloseToBottom =
            layoutMeasurement.height + contentOffset.y >= contentSize.height - 30;
          setIsAtBottom(isCloseToBottom);
          if (isCloseToBottom) setUnreadCount(0);
        }}
        scrollEventThrottle={100}
      />

      {/* Botão flutuante "Novas mensagens" quando pausado */}
      {!isAtBottom && unreadCount > 0 && (
        <TouchableOpacity
          style={styles.unreadPill}
          onPress={scrollToBottom}
          activeOpacity={0.8}
        >
          <Text style={styles.unreadText}>↓ Novas mensagens ({unreadCount})</Text>
        </TouchableOpacity>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    maxHeight: 280,
    width: '85%',
    justifyContent: 'flex-end',
  },
  listContent: {
    paddingHorizontal: 8,
    paddingBottom: 8,
    justifyContent: 'flex-end',
  },
  messageRow: {
    marginVertical: 3,
    alignSelf: 'flex-start',
    maxWidth: '100%',
  },
  // A famosa cápsula semi-transparente fosca do TikTok
  bubble: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    backgroundColor: 'rgba(0, 0, 0, 0.42)', // Tom escuro suave com transparência de iPhone
    borderRadius: 16,
    paddingHorizontal: 9,
    paddingVertical: 5,
    maxWidth: '100%',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.15,
        shadowRadius: 2,
      },
      android: {
        elevation: 1,
      },
    }),
  },
  avatar: {
    width: 22,
    height: 22,
    borderRadius: 11,
    marginRight: 6,
    marginTop: 2,
  },
  avatarPlaceholder: {
    backgroundColor: '#4B5563',
    alignItems: 'center',
    justifyContent: 'center',
  },
  avatarInitial: {
    color: '#FFF',
    fontSize: 10,
    fontWeight: '700',
  },
  commentContent: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'center',
    flexShrink: 1,
  },
  badgesRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginRight: 4,
    marginBottom: 1,
  },
  badgePill: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 5,
    height: 15,
    borderRadius: 7.5,
    marginRight: 4,
  },
  badgeIcon: {
    color: '#FFF',
    fontSize: 8,
    marginRight: 2,
  },
  badgeText: {
    color: '#FFF',
    fontSize: 9,
    fontWeight: '700',
    letterSpacing: -0.2,
  },
  textContainer: {
    flexShrink: 1,
  },
  // Nome do usuário no estilo iPhone SF Pro (peso 600, cinza claro)
  usernameText: {
    fontSize: 13.5,
    fontWeight: '600',
    color: 'rgba(255, 255, 255, 0.72)',
    fontFamily: Platform.OS === 'ios' ? 'SF Pro Text' : 'sans-serif-medium',
  },
  // Texto do comentário: branco puro, nítido
  commentText: {
    fontSize: 13.5,
    fontWeight: '400',
    color: '#FFFFFF',
    lineHeight: 18,
    fontFamily: Platform.OS === 'ios' ? 'SF Pro Text' : 'sans-serif',
  },
  // Evento de entrada ("fulano entrou")
  joinBubble: {
    backgroundColor: 'rgba(0, 0, 0, 0.32)',
    paddingVertical: 3.5,
    paddingHorizontal: 10,
    borderRadius: 14,
  },
  joinText: {
    fontSize: 12,
    color: 'rgba(255, 255, 255, 0.85)',
  },
  joinIcon: {
    fontSize: 11,
  },
  joinUsername: {
    fontWeight: '600',
    color: '#FDE047', // Toque dourado do TikTok
  },
  // Evento de presente
  giftBubble: {
    backgroundColor: 'rgba(254, 44, 85, 0.28)', // Tint avermelhado/rosa suave de presente
    borderWidth: 1,
    borderColor: 'rgba(254, 44, 85, 0.45)',
    alignItems: 'center',
  },
  giftInfo: {
    marginRight: 8,
  },
  giftSubtitle: {
    fontSize: 12,
    color: '#FFF',
    fontWeight: '500',
  },
  giftIcon: {
    fontSize: 14,
  },
  comboBadge: {
    paddingHorizontal: 6,
    paddingVertical: 2,
  },
  comboText: {
    fontSize: 16,
    fontWeight: '900',
    fontStyle: 'italic',
    color: '#FDE047',
    textShadowColor: 'rgba(0, 0, 0, 0.75)',
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 3,
  },
  // Alerta de novas mensagens
  unreadPill: {
    position: 'absolute',
    bottom: 4,
    alignSelf: 'center',
    backgroundColor: 'rgba(254, 44, 85, 0.95)',
    paddingVertical: 4,
    paddingHorizontal: 12,
    borderRadius: 14,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.3,
    shadowRadius: 4,
  },
  unreadText: {
    color: '#FFFFFF',
    fontSize: 11.5,
    fontWeight: '700',
  },
});

export default TikTokLiveChat;
