CREATE OR REPLACE VIEW v_arus_kas_per_aktivitas AS
SELECT 
    [link mencurigakan dihapus]_flow_activity AS aktivitas,
    SUM(l.debit - [link mencurigakan dihapus]) AS arus_kas_bersih
FROM journal_lines l
JOIN journal_headers h ON l.header_id = [link mencurigakan dihapus]
JOIN chart_of_accounts c ON l.account_id = c.account_id
WHERE h.posting_status = 'POSTED'
  AND h.journal_type <> 'MUTASI_KAS' -- Mengecualikan transfer internal (PSAK 207)
  AND [link mencurigakan dihapus]_classification IN ('KAS', 'SETARA_KAS')
GROUP BY [link mencurigakan dihapus]_flow_activity;
