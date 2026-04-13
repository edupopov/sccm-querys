-- ==========================================
-- Contagem de status BitLocker (dinâmico)
-- Autor: Eduardo Popovici + Comentado pelo Copilot :)
-- Objetivo: contar Criptografado / Não criptografado / Desconhecido
--           com SELECT dinâmico (sp_executesql) e parâmetro opcional de coleção
-- ==========================================
DECLARE 
      @CollectionID  NVARCHAR(50) = NULL   -- ex.: 'XYZ000AB' ou NULL para todo ambiente
    , @OnlyActive    BIT = 1               -- 1 = somente clientes ativos e não obsoletos (recomendado)
    , @Sql           NVARCHAR(MAX)
    , @Params        NVARCHAR(200);

SET @Params = N'@CollectionID NVARCHAR(50), @OnlyActive BIT';

-- Monta o FROM/JOINS base
DECLARE @FromJoins NVARCHAR(MAX) = N'
FROM v_R_System rs
JOIN v_GS_COMPUTER_SYSTEM cs
      ON cs.ResourceID = rs.ResourceID
LEFT JOIN (
    -- Consolidar o volume C: (prioritário) e evitar duplicidades
    SELECT ev.ResourceID,
           ev.ProtectionStatus0,
           ROW_NUMBER() OVER (PARTITION BY ev.ResourceID ORDER BY CASE WHEN ev.DriveLetter0 = ''C:'' THEN 0 ELSE 1 END) AS rn
    FROM v_GS_ENCRYPTABLE_VOLUME ev
    WHERE ev.DriveLetter0 = ''C:''
) AS v
      ON v.ResourceID = rs.ResourceID
     AND v.rn = 1
';

-- Opcional: escopo por coleção
IF @CollectionID IS NOT NULL
BEGIN
    SET @FromJoins = N'
FROM v_R_System rs
JOIN v_FullCollectionMembership fcm
      ON fcm.ResourceID = rs.ResourceID
JOIN v_GS_COMPUTER_SYSTEM cs
      ON cs.ResourceID = rs.ResourceID
LEFT JOIN (
    SELECT ev.ResourceID,
           ev.ProtectionStatus0,
           ROW_NUMBER() OVER (PARTITION BY ev.ResourceID ORDER BY CASE WHEN ev.DriveLetter0 = ''C:'' THEN 0 ELSE 1 END) AS rn
    FROM v_GS_ENCRYPTABLE_VOLUME ev
    WHERE ev.DriveLetter0 = ''C:''
) AS v
      ON v.ResourceID = rs.ResourceID
     AND v.rn = 1
';
END;

-- WHERE dinâmico
DECLARE @Where NVARCHAR(MAX) = N' WHERE 1=1 ';

IF @OnlyActive = 1
BEGIN
    SET @Where += N' AND rs.Client0 = 1 AND rs.Obsolete0 = 0 ';
END;

IF @CollectionID IS NOT NULL
BEGIN
    SET @Where += N' AND fcm.CollectionID = @CollectionID ';
END;

-- SELECT de contagem com mapeamento de status
-- 0 = Não criptografado | 1 = Criptografado | (NULL ou outros) = Desconhecido
SET @Sql = N'
SELECT
      SUM(CASE WHEN v.ProtectionStatus0 = 1 THEN 1 ELSE 0 END) AS Criptografados
    , SUM(CASE WHEN v.ProtectionStatus0 = 0 THEN 1 ELSE 0 END) AS NaoCriptografados
    , SUM(CASE WHEN v.ProtectionStatus0 NOT IN (0,1) OR v.ProtectionStatus0 IS NULL THEN 1 ELSE 0 END) AS Desconhecidos
' + @FromJoins + @Where + N';';

-- Debug opcional:
-- PRINT @Sql;

EXEC sp_executesql @Sql, @Params, @CollectionID = @CollectionID, @OnlyActive = @OnlyActive;
