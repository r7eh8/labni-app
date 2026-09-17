import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const LabniApp());
}

class LabniApp extends StatelessWidget {
  const LabniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'لعبني - Labni',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF6C5CE7),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C5CE7),
          secondary: Color(0xFF00FFAB),
          surface: Color(0xFF1E1E2C),
        ),
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      ),
      home: const HomeScreen(),
    );
  }
}

class PlayerRequest {
  final String id;
  final String playerName;
  final String gameName;
  final String gameId;
  final String rank;
  final int neededPlayers;
  final bool hasMic;
  final String roomId;

  PlayerRequest({
    required this.id,
    required this.playerName,
    required this.gameName,
    required this.gameId,
    required this.rank,
    required this.neededPlayers,
    required this.hasMic,
    required this.roomId,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedGame = 'الكل';

  final List<Map<String, String>> games = [
    {'name': 'الكل', 'icon': '🎮'},
    {'name': 'PUBG Mobile', 'icon': '🪖'},
    {'name': 'eFootball (بيس)', 'icon': '⚽'},
    {'name': 'Call of Duty', 'icon': '🎯'},
    {'name': 'Free Fire', 'icon': '🔥'},
  ];

  List<PlayerRequest> requests = [
    PlayerRequest(
      id: '1',
      playerName: 'يونس_الجيمر',
      gameName: 'PUBG Mobile',
      gameId: '5123456789',
      rank: 'ماهر / Ace',
      neededPlayers: 2,
      hasMic: true,
      roomId: 'room_pubg_01',
    ),
    PlayerRequest(
      id: '2',
      playerName: 'Legend_88',
      gameName: 'eFootball (بيس)',
      gameId: '987-654-321',
      rank: 'تحدي 1v1 ودي',
      neededPlayers: 1,
      hasMic: false,
      roomId: 'room_pes_02',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredRequests = selectedGame == 'الكل'
        ? requests
        : requests.where((r) => r.gameName == selectedGame).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('لعبني 🎮', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                final isSelected = selectedGame == game['name'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: FilterChip(
                    label: Text('${game['icon']} ${game['name']}'),
                    selected: isSelected,
                    selectedColor: const Color(0xFF6C5CE7),
                    backgroundColor: const Color(0xFF1E1E2C),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        selectedGame = game['name']!;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: filteredRequests.isEmpty
                ? const Center(child: Text('لا توجد طلبات حالياً، كن أول من ينشر!'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      final req = filteredRequests[index];
                      return Card(
                        color: const Color(0xFF1E1E2C),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    req.playerName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF00FFAB)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C5CE7).withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(req.gameName, style: const TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('الرانك / النمط: ${req.rank}', style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text('الـ ID: ${req.gameId}'),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 18, color: Color(0xFF00FFAB)),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: req.gameId));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('تم نسخ الـ ID بنجاح!')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        req.hasMic ? Icons.mic : Icons.mic_off,
                                        color: req.hasMic ? Colors.green : Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(req.hasMic ? 'المايك متوفر' : 'بدون مايك'),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6C5CE7),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.headset, size: 18),
                                    label: const Text('دخول الروم الصوتي'),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VoiceRoomScreen(
                                            roomId: req.roomId,
                                            gameName: req.gameName,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00FFAB),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('أضف طلبك', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: () {
          _showAddRequestDialog(context);
        },
      ),
    );
  }

  void _showAddRequestDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController();
    final rankCtrl = TextEditingController();
    String game = 'PUBG Mobile';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('انشر طلب بحث عن لاعبين 🎮', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسمك باللعبة')),
            TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'الـ ID الخاص بك')),
            TextField(controller: rankCtrl, decoration: const InputDecoration(labelText: 'الرانك / المستوى')),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), minimumSize: const Size.fromHeight(45)),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && idCtrl.text.isNotEmpty) {
                  setState(() {
                    requests.insert(
                      0,
                      PlayerRequest(
                        id: DateTime.now().toString(),
                        playerName: nameCtrl.text,
                        gameName: game,
                        gameId: idCtrl.text,
                        rank: rankCtrl.text.isEmpty ? 'عام' : rankCtrl.text,
                        neededPlayers: 2,
                        hasMic: true,
                        roomId: 'room_${DateTime.now().millisecondsSinceEpoch}',
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('نشر الطلب'),
            )
          ],
        ),
      ),
    );
  }
}

class VoiceRoomScreen extends StatefulWidget {
  final String roomId;
  final String gameName;

  const VoiceRoomScreen({super.key, required this.roomId, required this.gameName});

  @override
  State<VoiceRoomScreen> createState() => _VoiceRoomScreenState();
}

class _VoiceRoomScreenState extends State<VoiceRoomScreen> {
  int? _remoteUid;
  bool _isJoined = false;
  bool _isMuted = false;
  late RtcEngine _engine;

  final String appId = "d36b1599cb51437ab653735cdc950542";

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine.enableAudio();
    await _engine.joinChannel(
      token: "",
      channelId: widget.roomId,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('غرفة الصوت - ${widget.gameName}'),
        backgroundColor: const Color(0xFF1E1E2C),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF6C5CE7),
              child: Icon(Icons.headset, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              _isJoined ? 'أنت متصل بالروم الصوتي 🎙️' : 'جاري الاتصال بالروم...',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _remoteUid != null ? 'لاعب آخر متصل معك حالياً' : 'في انتظار انضمام باقي اللاعبين...',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'mic',
                  backgroundColor: _isMuted ? Colors.red : const Color(0xFF00FFAB),
                  onPressed: () {
                    setState(() {
                      _isMuted = !_isMuted;
                    });
                    _engine.muteLocalAudioStream(_isMuted);
                  },
                  child: Icon(_isMuted ? Icons.mic_off : Icons.mic, color: Colors.black),
                ),
                const SizedBox(width: 30),
                FloatingActionButton(
                  heroTag: 'leave',
                  backgroundColor: Colors.red,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
