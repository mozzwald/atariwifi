#include "voice.h"

#define EOL 0x9B

void sioVoice::sio_sam()
{
    int n = 3;
    char *a[3];
    a[0] = (char*)("sam");
    a[1] = (char*)("-debug");
    int i = 0;
    while (buffer[i] != EOL && i < 39)
    {
        i++;
    }
    buffer[i] = '\0';
    a[2] = (char *)buffer;
    sam(n, a);
};

void sioVoice::sio_write()
{
    // act like a printer for POC
    byte n = 40;
    byte ck;

    memset(buffer, 0, n); // clear buffer

    ck = sio_to_peripheral(buffer, n);

    if (ck == sio_checksum(buffer, n))
    {
        sio_sam();
        sio_complete();
    }
    else
    {
        sio_error();
    }
}

// Status
void sioVoice::sio_status()
{
    // act like a printer for POC
    byte status[4];

    status[0] = 0;
    status[1] = lastAux1;
    status[2] = 5;
    status[3] = 0;

    sio_to_computer(status, sizeof(status), false);
}

void sioVoice::sio_process()
{
    // act like a printer for POC
    switch (cmdFrame.comnd)
    {
    case 'P': // 0x50
    case 'W': // 0x57
        sio_ack();
        sio_write();
        lastAux1 = cmdFrame.aux1;
        break;
    case 'S': // 0x53
        sio_ack();
        sio_status();
        break;
    default:
        sio_nak();
    }
}
