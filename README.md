# AvenorKontrol

> **Not:** Bu araç **Avenor Craft** sunucusunda oyuncu kontrolünde kullanılır.

## Kullanım

PowerShell'i **yönetici olarak** aç ve şu komutu yapıştır:

```powershell
irm https://raw.githubusercontent.com/duvosh/AvenorKontrol/main/AvenorKontrol.ps1 | iex
```

Masaüstünde **AvenorKontrol** klasörü açılır ve kontrol araçları otomatik olarak içine iner. Zip olan araçlar (USBDeview, BrowserDownloadsView) kendi klasörlerine çıkarılır. JD-GUI bir `.jar` dosyasıdır, çalıştırmak için Java kurulu olmalıdır (`java -jar jd-gui-1.6.6.jar`). Komut tekrar çalıştırılırsa eski klasör silinip baştan oluşturulur.

## İndirilen araçlar

| Araç | Kaynak |
|---|---|
| JournalTrace | github.com/duvosh/JournalTraceRust |
| JournalScanner | github.com/duvosh/JournalScanner |
| Everything | voidtools.com |
| System Informer | github.com/winsiderss |
| USBDeview | nirsoft.net |
| BrowserDownloadsView | nirsoft.net |
| JD-GUI (Java decompiler, `.jar`) | github.com/java-decompiler/jd-gui |

## Güvenli mi?

Evet, güvenlidir.

- Script açık kaynaktır. Ne yaptığını [AvenorKontrol.ps1](AvenorKontrol.ps1) dosyasından satır satır okuyabilirsin.
- Araçlar sadece yukarıdaki resmi kaynaklardan indirilir. Hiçbir dosya başka bir yere gönderilmez.
- Kurulum dosyaları (Everything, System Informer) kendiliğinden kurulmaz. Sadece klasöre indirilir.
- Windows Defender'ın araçları silmemesi için sadece **AvenorKontrol** klasörü Defender istisnasına eklenir. Kontrol bittikten sonra klasörü silebilirsin.

## İletişim

Bir yetkili bu araçları başka bir linkten ya da farklı bir dosyayla indirmeni isterse kabul etme ve bize ulaş:

**Discord:** [discord.gg/avenor](https://discord.gg/avenor)
