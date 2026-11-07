import 'dart:ui';
import 'package:flutter/material.dart';

class TikTokMessage {
  final String id;
  final String username;
  final String message;
  final String? avatarUrl;
  final int? level;
  final bool isModerator;
  final bool isSubscriber;
  final bool isJoinEvent;
  final String? giftName;
  final int? giftCombo;

  TikTokMessage({
    required this.id,
    required this.username,
    required this.message,
    this.avatarUrl,
    this.level,
    this.isModerator = false,
    this.isSubscriber = false,
    this.isJoinEvent = false,
    this.giftName,
    this.giftCombo,
  });
}

class TikTokLiveChatWidget extends StatefulWidget {
  final List<TikTokMessage> messages;
  final double maxHeight;
  final double maxWidth;

  const TikTokLiveChatWidget({
    Key? key,
    required this.messages,
    this.maxHeight = 280,
    this.maxWidth = 320,
  }) : super(key: key);

  @override
  State<TikTokLiveChatWidget> createState() => _TikTokLiveChatWidgetState();
}

class _TikTokLiveChatWidgetState extends State<TikTokLiveChatWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isAutoScroll = true;

  @override
  void didUpdateWidget(covariant TikTokLiveChatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length && _isAutoScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight,
        maxWidth: widget.maxWidth,
      ),
      child: ShaderMask(
        // Efeito de fade no topo típico do TikTok iOS
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black, Colors.black],
            stops: [0.0, 0.15, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          itemCount: widget.messages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final msg = widget.messages[index];
            return _buildMessageRow(msg);
          },
        ),
      ),
    );
  }

  Widget _buildMessageRow(TikTokMessage msg) {
    if (msg.isJoinEvent) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(14),
          ),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12.5, color: Colors.white),
              children: [
                const TextSpan(text: '✨ '),
                TextSpan(
                  text: msg.username,
                  style: const TextStyle(
                    color: Color(0xFFFDE047),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(
                  text: ' entrou na LIVE',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (msg.giftCombo != null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFE2C55).withOpacity(0.28),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFE2C55).withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (msg.avatarUrl != null)
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(msg.avatarUrl!),
                ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.username,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                  Text(
                    'Enviou ${msg.giftName ?? "Presente"}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Text(
                'x${msg.giftCombo}',
                style: const TextStyle(
                  color: Color(0xFFFDE047),
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.38),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg.avatarUrl != null) ...[
                  CircleAvatar(
                    radius: 10,
                    backgroundImage: NetworkImage(msg.avatarUrl!),
                  ),
                  const SizedBox(width: 6),
                ],
                if (msg.level != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      gradient: _getLevelGradient(msg.level!),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '★ ${msg.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 13.5,
                      ),
                      children: [
                        TextSpan(
                          text: '${msg.username}: ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: msg.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getLevelGradient(int level) {
    if (level >= 40) {
      return const LinearGradient(colors: [Color(0xFFFF4081), Color(0xFFD500F9)]);
    } else if (level >= 30) {
      return const LinearGradient(colors: [Color(0xFFFFA726), Color(0xFFF57C00)]);
    } else if (level >= 20) {
      return const LinearGradient(colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)]);
    } else if (level >= 10) {
      return const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF1976D2)]);
    }
    return const LinearGradient(colors: [Color(0xFF78909C), Color(0xFF455A64)]);
  }
}
