#!/usr/bin/env bash
# 批次下載「開放取用（Open Access）」論文 PDF
# 用法：bash download_oa_pdfs.sh
#
# 策略說明：
#   多數期刊網站（MDPI、PNAS、Springer、PMC 網頁版）會以 Cloudflare / bot 偵測
#   擋掉 curl，導致「下載成功但存到的是 HTML 挑戰頁」。因此本腳本優先使用
#   Europe PMC 的 ?pdf=render 端點（不擋機器人），僅在無 PMCID 時才回退到出版社。
#   每篇下載後都以 `file --mime-type` 驗證確實是 PDF，避免 HTML 偽裝成 .pdf。
#
# 付費牆論文不含在內，需透過機構訂閱取得。

set -u
OUT="oa_pdfs"
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36"
mkdir -p "$OUT"

# 格式： 檔名|PMCID（有 PMCID 者走 Europe PMC）
VIA_EPMC=(
  "02_Recife_ENSO_dengue_RevSocBrasMedTrop.pdf|PMC9176733"
  "09_ClimateChange_InfectiousDiseases_PHR.pdf|PMC5810060"
  "10_ColombianCaribbean_dengue_ONI_Biomedica.pdf|PMC12755388"
  "15_Parana_Aedes_oviposition_TropMedInfectDis.pdf|PMC9501904"
  "18_Albopictus_rainfall_temp_model_IJERPH.pdf|PMC3709343"
  "22_Brisbane_rainwater_tanks_BiolInvasions.pdf|PMC8386157"
  "24_Guangzhou_climate_dengue_PNAS.pdf|PMC5224358"
)

# 格式： 檔名|網址（出版社直連可用者）
VIA_PUBLISHER=(
  "03_SaoPaulo_ENSO_Aedes_PLoSNTD.pdf|https://journals.plos.org/plosntds/article/file?id=10.1371/journal.pntd.0012397&type=printable"
  "04_SouthTaiwan_dengue_climate_PLoSOne.pdf|https://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0178698&type=printable"
  "05_Peru_weather_climate_dengue_PLoSNTD.pdf|https://journals.plos.org/plosntds/article/file?id=10.1371/journal.pntd.0010479&type=printable"
  "07_Venezuela_ENSO_dengue_SciRep.pdf|https://www.nature.com/articles/s41598-018-24003-z.pdf"
  "11_Aedes_egg_morphology_ParasitVectors.pdf|https://parasitesandvectors.biomedcentral.com/counter/pdf/10.1186/s13071-021-05024-6.pdf"
  "17_CentralAfrica_urbanization_Aedes_ParasitVectors.pdf|https://parasitesandvectors.biomedcentral.com/counter/pdf/10.1186/s13071-025-06764-5.pdf"
)

ok=0; fail=0

# 下載後驗證 MIME；非 PDF 一律刪除並計為失敗
fetch() {
  local name="$1" url="$2"
  echo "→ $name"
  if curl -fsSL --retry 3 -A "$UA" -H "Accept: application/pdf,*/*" "$url" -o "$OUT/$name" \
     && [ "$(file -b --mime-type "$OUT/$name")" = "application/pdf" ]; then
    ok=$((ok+1))
  else
    echo "   失敗（取得非 PDF 內容或連線錯誤）：$url"
    rm -f "$OUT/$name"
    fail=$((fail+1))
  fi
}

echo "開始下載開放取用論文 PDF 至 ./$OUT/ ..."

for entry in "${VIA_EPMC[@]}"; do
  fetch "${entry%%|*}" "https://europepmc.org/articles/${entry#*|}?pdf=render"
done

for entry in "${VIA_PUBLISHER[@]}"; do
  fetch "${entry%%|*}" "${entry#*|}"
done

echo "-----------------------------------------"
echo "完成：成功 $ok 篇，失敗 $fail 篇。檔案位於 ./$OUT/"
echo
echo "以下 2 篇為開放取用但受 Cloudflare 阻擋，請用瀏覽器手動下載："
echo "  19  Salud Publica Mex  https://doi.org/10.21149/8141"
echo "  21  Int Health         https://doi.org/10.1093/inthealth/iht023"
echo "付費牆論文請透過機構訂閱、館際互借或向作者索取。"
