#ifndef NETWORKPROTOCOLHTTP
#define NETWORKPROTOCOLHTTP

#include <Arduino.h>
#include <HTTPClient.h>
#include "networkProtocol.h"
#include "networkDeviceSpec.h"
#include "sio.h"

class networkProtocolHTTP : public networkProtocol
{
public:
    networkProtocolHTTP();
    virtual ~networkProtocolHTTP();

    virtual bool open(networkDeviceSpec *spec, cmdFrame_t* cmdFrame);
    virtual bool close();
    virtual bool read(byte *rx_buf, unsigned short len);
    virtual bool write(byte *tx_buf, unsigned short len);
    virtual bool status(byte *status_buf);
    virtual bool special(byte *sp_buf, unsigned short len, cmdFrame_t *cmdFrame);

private:
    virtual bool startConnection();

    HTTPClient client;
    bool requestStarted = false;
    enum {GET, POST, PUT} openMode;
};

#endif /* NETWORKPROTOCOLHTTP */