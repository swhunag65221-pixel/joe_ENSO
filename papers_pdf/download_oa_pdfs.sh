#!/usr/bin/env bash
# 批次下載「開放取用（Open Access）」論文 PDF
# 用法：在你自己的電腦（可正常連網）執行  bash download_oa_pdfs.sh
# 說明：本雲端環境的網路政策封鎖期刊網站，故無法在雲端下載；請於本機執行本腳本。
# 付費牆論文不含在內，需透過機構訂閱取得。

set -u
OUT="oa_pdfs"
mkdir -p "$OUT"

# 格式： 檔名|網址
DOWNLOADS=(
  "03_SaoPaulo_ENSO_Aedes_PLoSNTD.pdf|https://journals.plos.org/plosntds/article/file?id=10.1371/journal.pntd.0012397&type=printable"
  "04_SouthTaiwan_dengue_climate_PLoSOne.pdf|https://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0178698&type=printable"
  "05_Peru_weather_climate_dengue_PLoSNTD.pdf|https://journals.plos.org/plosntds/article/file?id=10.1371/journal.pntd.0010479&type=printable"
  "07_Venezuela_ENSO_dengue_SciRep.pdf|https://www.nature.com/articles/s41598-018-24003-z.pdf"
  "09_ClimateChange_InfectiousDiseases_PHR.pdf|https://pmc.ncbi.nlm.nih.gov/articles/PMC5810060/pdf/"
  "11_Aedes_egg_morphology_ParasitVectors.pdf|https://parasitesandvectors.biomedcentral.com/counter/pdf/10.1186/s13071-021-05024-6.pdf"
  "15_Parana_Aedes_oviposition_TropMedInfectDis.pdf|https://www.mdpi.com/2414-6366/7/9/246/pdf"
  "17_CentralAfrica_urbanization_Aedes_ParasitVectors.pdf|https://parasitesandvectors.biomedcentral.com/counter/pdf/10.1186/s13071-025-06764-5.pdf"
  "18_Albopictus_rainfall_temp_model_IJERPH.pdf|https://www.mdpi.com/1660-4601/10/5/1698/pdf"
  "22_Brisbane_rainwater_tanks_BiolInvasions.pdf|https://link.springer.com/content/pdf/10.1007/s10530-021-02619-z.pdf"
  "24_Guangzhou_climate_dengue_PNAS.pdf|https://www.pnas.org/doi/pdf/10.1073/pnas.1618558114"
)

echo "開始下載開放取用論文 PDF 至 ./$OUT/ ..."
ok=0; fail=0
for entry in "${DOWNLOADS[@]}"; do
  name="${entry%%|*}"
  url="${entry#*|}"
  echo "→ $name"
  if curl -fSL --retry 3 -A "Mozilla/5.0" "$url" -o "$OUT/$name"; then
    ok=$((ok+1))
  else
    echo "   下載失敗（可能需在瀏覽器手動下載）：$url"
    fail=$((fail+1))
  fi
done

echo "-----------------------------------------"
echo "完成：成功 $ok 篇，失敗 $fail 篇。檔案位於 ./$OUT/"
echo "付費牆論文請透過機構訂閱、館際互借或向作者索取。"
