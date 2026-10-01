# Architecture

```text
                    Private Wi-Fi / LAN
                           |
        +------------------+------------------+
        |                  |                  |
     Mac 1              Mac 2              Mac 3             Mac 4
    Sankalp             Prateek             Yaseen        Mathapati/Sarthak
      DNS              nginx/TLS            Backend A        Backend B
    UDP 53               TCP 443             TCP 3001        TCP 3002
        |                  |
        +---- DNS -------->+---- HTTPS -----> A or B
```

Domain:
- `app.team1.test` -> Mac 2
- `api.team1.test` -> Mac 2

Client never uses the backend IP directly for the final HTTPS demonstration.
