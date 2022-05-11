local Translations = {
    error = {
        ["missing_something"] = "Valami még hiányzik...",
        ["not_enough_police"] = "Nincs elég rendvédelem..",
        ["door_open"] = "Már nyitva van..",
        ["process_cancelled"] = "Megszakítva..",
        ["didnt_work"] = "Nem sikerült..",
        ["emty_box"] = "Üres volt..",
    },
    success = {
        ["worked"] = "Sikerült!",
    }
}
Lang = Locale:new({
phrases = Translations,
warnOnMissing = true})