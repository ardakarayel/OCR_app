import easyocr

reader = easyocr.Reader(['tr'])
results = reader.readtext("images.jpeg", detail=0)

# Tüm satırları tek satır metne çevir
duz_metin = " ".join(results)
print(" ")
print(" ")

print("OCR sonucu (tek satır):")
print(duz_metin)
