#ifndef ATARI_1029_H
#define ATARI_1029_H

#include "pdf_printer.h"

typedef uint8_t byte;

class atari1029 : public pdfPrinter
{
protected:
    struct epson_cmd_t
    {
        uint8_t cmd;
        uint8_t N1;
        uint8_t N2;
        uint16_t N;
        uint16_t ctr;
    } epson_cmd = {0, 0, 0, 0};
    bool escMode = false;

    const uint16_t fnt_underline = 0x001;
    const uint16_t fnt_expanded = 0x002;
    const uint16_t fnt_intl = 0x100;

    uint16_t epson_font_mask = 0; // need to set to normal TODO

    void print_8bit_gfx(uint8_t c);
    void not_implemented();
    void esc_not_implemented();
    void set_mode(uint16_t m);
    void clear_mode(uint16_t m);
    void reset_cmd();
    uint8_t epson_font_lookup(uint16_t code);
    float epson_font_width(uint16_t code);
    void epson_set_font(uint8_t F, float w);

    virtual void pdf_clear_modes() override{};
    void pdf_handle_char(uint8_t c, uint8_t aux1, uint8_t aux2) override;
    virtual void post_new_file() override;

public:
    const char *modelname() { return "Atari 1029"; };
};

#endif