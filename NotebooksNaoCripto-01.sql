-- ==========================================
-- Notebooks NÃO criptografados (VERSÃO ROBUSTA)
-- ==========================================

DECLARE 
      @OnlyActive BIT = 1;

SELECT
      rs.Name0                                  AS Nome
    , 'Notebook'                                AS Tipo
    , os.Caption0                               AS SistemaOperacional
    , CASE 
          WHEN v.ProtectionStatus0 = 1 THEN 'Criptografado'
          WHEN v.ProtectionStatus0 = 0 THEN 'Não Criptografado'
          ELSE 'Desconhecido'
      END                                        AS BitLockerStatus
    , cs.Manufacturer0                          AS Vendor

FROM v_R_System rs

JOIN v_GS_COMPUTER_SYSTEM cs
    ON cs.ResourceID = rs.ResourceID

LEFT JOIN v_GS_OPERATING_SYSTEM os
    ON os.ResourceID = rs.ResourceID

LEFT JOIN (
    SELECT ev.ResourceID,
           ev.ProtectionStatus0,
           ROW_NUMBER() OVER (
                PARTITION BY ev.ResourceID 
                ORDER BY CASE WHEN ev.DriveLetter0 = 'C:' THEN 0 ELSE 1 END
           ) AS rn
    FROM v_GS_ENCRYPTABLE_VOLUME ev
    WHERE ev.DriveLetter0 = 'C:'
) v
    ON v.ResourceID = rs.ResourceID
   AND v.rn = 1

-- Aqui está o segredo
JOIN v_GS_SYSTEM_ENCLOSURE se
    ON se.ResourceID = rs.ResourceID

WHERE 1=1

-- Apenas ativos
AND (@OnlyActive = 0 OR (rs.Client0 = 1 AND rs.Obsolete0 = 0))

-- Identificação de NOTEBOOK via chassis
AND se.ChassisTypes0 IN (
    8,   -- Portable
    9,   -- Laptop
    10,  -- Notebook
    11,  -- Hand Held
    12,  -- Docking Station
    14   -- Sub Notebook
)

-- Apenas NÃO criptografados
AND (
        v.ProtectionStatus0 = 0
     OR v.ProtectionStatus0 IS NULL
)

ORDER BY rs.Name0;
