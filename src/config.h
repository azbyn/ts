#ifndef CONFIG_H
#define CONFIG_H
namespace config {
constexpr char fontPath[] = ":/fonts/DejaVuSansMono.ttf";
constexpr int fontSize = (sizeof(void*) == 8) ? 14 : 16;//for testing
constexpr int fontSizeNumber = 20;
constexpr float cursorPerc = 0.2f;
constexpr bool hasLineNumbers = true;
constexpr int indentSize = 4;
}
#endif
