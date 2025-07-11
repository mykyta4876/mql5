#include <Controls\Defines.mqh>

#undef CONTROLS_FONT_NAME
#undef CONTROLS_FONT_SIZE
#undef CONTROLS_LABEL_COLOR

#undef CONTROLS_BUTTON_COLOR
#undef CONTROLS_BUTTON_COLOR_BG
#undef CONTROLS_BUTTON_COLOR_BORDER

#undef CONTROLS_DIALOG_COLOR_BORDER_LIGHT
#undef CONTROLS_DIALOG_COLOR_BORDER_DARK
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BORDER


#define CONTROLS_LABEL_COLOR              in_painel_font_color1
#define CONTROLS_FONT_NAME                in_painel_font_name
#define CONTROLS_FONT_SIZE                in_painel_fontSize1

#define CONTROLS_BUTTON_COLOR             in_painel_button_color
#define CONTROLS_BUTTON_COLOR_BG          in_painel_button_color_bg
#define CONTROLS_BUTTON_COLOR_BORDER      in_painel_button_color_border

#define CONTROLS_DIALOG_COLOR_BORDER_LIGHT in_painel_dialog_color_border_light
#define CONTROLS_DIALOG_COLOR_BORDER_DARK in_painel_dialog_color_border_dark
#define CONTROLS_DIALOG_COLOR_BG          in_painel_dialog_color_bg
#define CONTROLS_DIALOG_COLOR_CAPTION_TEXT in_painel_dialog_color_caption_text
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   in_painel_dialog_color_client_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BORDER in_painel_dialog_color_client_border



 string in_painel_title = "+"; //Title
 bool in_painel_use_init_file = true; //Save Last Position
 ENUM_ANCHOR_POINT in_painel_anchor = ANCHOR_RIGHT_LOWER; //Anchor
 int in_painel_x = 2; //X offset (from anchor)
 int in_painel_y = 2; //Y offset (from anchor)
 int in_painel_width = 500; //Width
 int in_painel_height = 450; //Height
 color in_painel_font_color1 = clrBlack;        //Fonte Cor 

 string   in_painel_font_name                  = "Arial Black"; //Fonte Nome
 int      in_painel_fontSize1                  = 9; // Fonte Size 

 color    in_painel_button_color               = clrWhite; //Button Color
 color    in_painel_button_color_bg            = clrBlack; //Button Backgroud
 color    in_painel_button_color_border        = clrGray; //Button Border

 color    in_painel_dialog_color_border_light  = clrWhite;   //Border 1
 color    in_painel_dialog_color_border_dark   = clrWhite;   //Border 2
 color    in_painel_dialog_color_client_border = clrWhite;   //Border 3
 color    in_painel_dialog_color_bg            = clrBlack;   //Background 1
 color    in_painel_dialog_color_client_bg     = clrWhite;   //Background 2
 color    in_painel_dialog_color_caption_text  = clrGray;    //Title