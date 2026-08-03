import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LabirentOyunPage extends StatefulWidget {
  final int gridWidth;
  const LabirentOyunPage({super.key, required this.gridWidth});

  @override
  State<LabirentOyunPage> createState() => _LabirentOyunPageState();
}

class _LabirentOyunPageState extends State<LabirentOyunPage> {
  late int _mazeWidth, _mazeHeight;
  late List<List<int>> _maze;
  
  List<Offset> _trail = [];
  Offset? _ballPos;
  late Offset _startCell;
  late Offset _exitCell;
  
  int _lives = 5;
  int _currentSetIndex = 1;
  bool _isTransitioning = false;
  DateTime _lastHitTime = DateTime.now();

  double _cellSize = 0;

  @override
  void initState() {
    super.initState();
    _generateRealMaze();
  }

  void _generateRealMaze() {
    _mazeWidth = widget.gridWidth;
    if (_mazeWidth % 2 == 0) _mazeWidth++;
    
    // 3:4 Ekran oranına uyan yüksekliği ayarla
    _mazeHeight = (_mazeWidth * 4) ~/ 3;
    if (_mazeHeight % 2 == 0) _mazeHeight++;

    _maze = List.generate(_mazeHeight, (_) => List.filled(_mazeWidth, 1));
    _carvePath(1, 1);

    // Giriş kapısı (Sol duvarın üst kısımları)
    _startCell = const Offset(0, 1);
    _maze[1][0] = 0; 
    
    // Çıkış kapısı (Alt duvarın sağ kısımları)
    _exitCell = Offset((_mazeWidth - 2).toDouble(), (_mazeHeight - 1).toDouble());
    _maze[_mazeHeight - 1][_mazeWidth - 2] = 0;
    
    _ballPos = null; 
    _trail.clear();
  }

  void _carvePath(int x, int y) {
    _maze[y][x] = 0;
    List<List<int>> dirs = [[0, -2], [0, 2], [-2, 0], [2, 0]]..shuffle(Random());
    for (var dir in dirs) {
      int nx = x + dir[0], ny = y + dir[1];
      if (nx > 0 && nx < _mazeWidth - 1 && ny > 0 && ny < _mazeHeight - 1 && _maze[ny][nx] == 1) {
        _maze[y + dir[1] ~/ 2][x + dir[0] ~/ 2] = 0;
        _carvePath(nx, ny);
      }
    }
  }

  bool _isSafe(Offset pos, double r, double padding) {
    int cx = (pos.dx / _cellSize).floor();
    int cy = (pos.dy / _cellSize).floor();

    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        int nx = cx + dx;
        int ny = cy + dy;

        if (nx >= 0 && nx < _mazeWidth && ny >= 0 && ny < _mazeHeight) {
          if (_maze[ny][nx] == 0) { 
            double left = nx * _cellSize - padding;
            double top = ny * _cellSize - padding;
            double right = (nx + 1) * _cellSize + padding;
            double bottom = (ny + 1) * _cellSize + padding;

            if (pos.dx >= left + r && pos.dx <= right - r &&
                pos.dy >= top + r && pos.dy <= bottom - r) {
              return true; 
            }
          }
        }
      }
    }
    return false;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isTransitioning || _ballPos == null) return;
    
    Offset proposedPos = _ballPos! + details.delta;
    
    double ballRadius = _cellSize * 0.20; 
    double pathPadding = _cellSize * 0.35; 

    // Dış Sınır Kontrolü
    if (proposedPos.dx < 0 || proposedPos.dx > _mazeWidth * _cellSize ||
        proposedPos.dy < 0 || proposedPos.dy > _mazeHeight * _cellSize) return;

    if (!_isSafe(proposedPos, ballRadius, pathPadding)) {
      // DUVARA ÇARPTI
      DateTime now = DateTime.now();
      if (now.difference(_lastHitTime) > const Duration(milliseconds: 500)) { 
        setState(() {
          _lives--;
          _lastHitTime = now;
        });
        
        if (_lives <= 0) {
          _showFailDialog();
        }
      }
    } else {
      // YOL AÇIK, İLERLE
      setState(() {
        _ballPos = proposedPos;
        if (_trail.isEmpty || (_trail.last - _ballPos!).distance > (_cellSize * 0.1)) {
          _trail.add(_ballPos!);
        }
      });
      _checkWinCondition();
    }
  }

  void _checkWinCondition() {
    // SADECE YEŞİL ALANIN (Çıkış Hücresinin) İÇİNE GİRDİĞİNDE KAZANIR
    int ballCellX = (_ballPos!.dx / _cellSize).floor();
    int ballCellY = (_ballPos!.dy / _cellSize).floor();

    if (ballCellX == _exitCell.dx.toInt() && ballCellY == _exitCell.dy.toInt()) {
      if (_currentSetIndex < 10) {
        setState(() { _isTransitioning = true; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harika! Sonraki bölüm...", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.green, duration: Duration(seconds: 1)));
        Timer(const Duration(seconds: 1), () {
          setState(() {
            _currentSetIndex++;
            _lives = 5;
            _isTransitioning = false;
            _generateRealMaze();
          });
        });
      } else {
        _showSuccessDialog();
      }
    }
  }

  void _showFailDialog() {
    setState(() { _isTransitioning = true; });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Canın Bitti! 🛑", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Labirenti tamamlarken çok fazla duvara çarptın. Yolu sıfırlıyorum, tekrar dene!", style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _lives = 5;
                _trail.clear();
                _ballPos = Offset((_startCell.dx + 0.5) * _cellSize, (_startCell.dy + 0.5) * _cellSize);
                _isTransitioning = false;
              });
            }, 
            child: Text("Tekrar Dene", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16))
          )
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Muhteşem! 🏆", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("10 labirentin tamamını başarıyla tamamladın!", textAlign: TextAlign.center, style: GoogleFonts.poppins()),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text("Menüye Dön", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold))),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/sayi_hafizasi_background_2.jpg', fit: BoxFit.cover)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(5, (index) => Icon(
                          index < _lives ? Icons.favorite : Icons.favorite_border,
                          color: Colors.redAccent, size: 28,
                        )),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFEE2B2B), borderRadius: BorderRadius.circular(20)),
                        child: Text("$_currentSetIndex / 10", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double targetAspect = 3 / 4;
                          double maxWidth = constraints.maxWidth;
                          double maxHeight = constraints.maxHeight;
                          double actualWidth, actualHeight;

                          if (maxWidth / maxHeight > targetAspect) {
                            actualHeight = maxHeight;
                            actualWidth = actualHeight * targetAspect;
                          } else {
                            actualWidth = maxWidth;
                            actualHeight = actualWidth / targetAspect;
                          }

                          _cellSize = actualWidth / _mazeWidth;
                          
                          _ballPos ??= Offset((_startCell.dx + 0.5) * _cellSize, (_startCell.dy + 0.5) * _cellSize);

                          return Container(
                            width: actualWidth,
                            height: actualHeight,
                            decoration: const BoxDecoration(
                              color: Colors.black, 
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                            ),
                            child: GestureDetector(
                              onPanUpdate: _onPanUpdate,
                              child: CustomPaint(
                                size: Size(actualWidth, actualHeight),
                                // Çıkış hücresini painter'a gönderiyoruz
                                painter: MazePainter(_maze, _trail, _cellSize, _ballPos!, _exitCell),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// İNCE DUVARLI LABİRENT ÇİZİM FIRÇASI
class MazePainter extends CustomPainter {
  final List<List<int>> maze;
  final List<Offset> trail;
  final double cellSize;
  final Offset ballPos;
  final Offset exitCell; // Bitiş hücresi verisi eklendi

  MazePainter(this.maze, this.trail, this.cellSize, this.ballPos, this.exitCell);

  @override
  void paint(Canvas canvas, Size size) {
    Paint pathPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    
    double p = cellSize * 0.35; 

    // 1. BEYAZ YOLLARI ÇİZ 
    for (int y = 0; y < maze.length; y++) {
      for (int x = 0; x < maze[y].length; x++) {
        if (maze[y][x] == 0) { 
          double left = x * cellSize - p;
          double top = y * cellSize - p;
          double right = (x + 1) * cellSize + p;
          double bottom = (y + 1) * cellSize + p;

          if (left < 0) left = 0;
          if (top < 0) top = 0;
          if (right > size.width) right = size.width;
          if (bottom > size.height) bottom = size.height;

          canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), pathPaint);
        }
      }
    }

    // 2. ÇIKIŞI GÖSTEREN YEŞİL BİTİŞ ALANI (YENİ EKLENDİ)
    Paint goalPaint = Paint()..color = Colors.green.withOpacity(0.8)..style = PaintingStyle.fill;
    double goalX = exitCell.dx * cellSize;
    double goalY = exitCell.dy * cellSize;
    // Çıkış hücresine tam oturan yeşil kare çizimi
    canvas.drawRect(Rect.fromLTWH(goalX, goalY, cellSize, cellSize), goalPaint);
    
    // Hedefin ortasına küçük dikkat çekici beyaz bir nokta
    Paint flagPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(goalX + cellSize / 2, goalY + cellSize / 2), cellSize * 0.15, flagPaint);

    // 3. GİRİŞİ GÖSTEREN YEŞİL OK
    Paint arrowPaint = Paint()..color = Colors.green..strokeWidth = cellSize * 0.2..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    double arrowX = 0; 
    double arrowY = 1.5 * cellSize; 
    canvas.drawLine(Offset(arrowX, arrowY), Offset(arrowX + cellSize * 0.6, arrowY), arrowPaint); 
    canvas.drawLine(Offset(arrowX + cellSize * 0.4, arrowY - cellSize * 0.2), Offset(arrowX + cellSize * 0.6, arrowY), arrowPaint); 
    canvas.drawLine(Offset(arrowX + cellSize * 0.4, arrowY + cellSize * 0.2), Offset(arrowX + cellSize * 0.6, arrowY), arrowPaint); 

    // 4. KULLANICININ ÇİZDİĞİ KIRMIZI İZ
    if (trail.isNotEmpty) {
      Paint trailPaint = Paint()..color = Colors.red..strokeWidth = cellSize * 0.15..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
      Path userPath = Path();
      userPath.moveTo(trail[0].dx, trail[0].dy);
      for (int i = 1; i < trail.length; i++) {
        userPath.lineTo(trail[i].dx, trail[i].dy);
      }
      canvas.drawPath(userPath, trailPaint);
    }

    // 5. SÜRÜKLENEN YEŞİL TOP
    Paint ballPaint = Paint()..color = Colors.green;
    canvas.drawCircle(ballPos, cellSize * 0.20, ballPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}