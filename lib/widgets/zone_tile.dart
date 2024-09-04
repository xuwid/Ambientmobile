import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ZoneTile extends StatefulWidget {
  final String zoneName;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ZoneTile({
    super.key,
    required this.zoneName,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<ZoneTile> createState() => _ZoneTileState();
}

class _ZoneTileState extends State<ZoneTile> {
  List<bool> portSelections = [false, false, false, false]; // For 4 ports
  int startingLight = 1;
  int endingLight = 12;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.zoneName,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: widget.onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: widget.onDelete,
              ),
            ],
          ),
          Row(
            children: List<Widget>.generate(4, (index) {
              return Expanded(
                child: Checkbox(
                  value: portSelections[index],
                  onChanged: (bool? value) {
                    setState(() {
                      portSelections[index] = value ?? false;
                    });
                  },
                  activeColor: Colors.purple,
                ),
              );
            }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLightControl("Starting Light", startingLight, (value) {
                setState(() {
                  startingLight = value;
                });
              }),
              _buildLightControl("Ending Light", endingLight, (value) {
                setState(() {
                  endingLight = value;
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLightControl(
      String label, int value, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(color: Colors.white),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (value > 1) {
                  onChanged(value - 1);
                }
              },
              icon: const Icon(Icons.remove, color: Colors.white),
            ),
            Text(
              value.toString(),
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
            IconButton(
              onPressed: () {
                onChanged(value + 1);
              },
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
