/* ======================================================================
   Consulta de Inventário – Valida compatibilidade BitLocker (TPM)
   Autor: Eduardo
   Revisão: otimizada e comentada pelo Copilot
   ====================================================================== */

SELECT DISTINCT
       rs.Name0                         AS [Host],
       cs.Manufacturer0                 AS [Vendor],
       cs.Model0                        AS [Modelo],

       -- Informações do Sistema Operacional
       os.Caption0                      AS [Sistema Operacional],
       os.BuildNumber0                  AS [Build],

       /* Normalização da release do Windows com base no BuildNumber.
          Observação:
          - MATCH por igualdade é 100% suficiente (ex.: 19045 = 22H2)
          - LIKE '19045%' funciona, mas não é necessário
       */
       CASE os.BuildNumber0
            WHEN '17763' THEN 'Windows 10 1809'
            WHEN '18363' THEN 'Windows 10 1909'
            WHEN '14393' THEN 'Windows 10 1607'
            WHEN '19044' THEN 'Windows 10 21H2'
            WHEN '19045' THEN 'Windows 10 22H2'
            WHEN '22621' THEN 'Windows 11 22H2'
            WHEN '22631' THEN 'Windows 11 23H2'
            WHEN '26100' THEN 'Windows 11 24H2'
            WHEN '26200' THEN 'Windows 11 25H2'
            ELSE 'N/D'
       END                              AS [Release],

       /* BitLocker exige TPM para ativação em modo total.
          Aqui verificamos se existe inventário TPM reportado.
          - Se houver entrada na v_GS_TPM → máquina compatível
       */
       CASE 
            WHEN tpm.SpecVersion0 IS NOT NULL THEN 'Sim'
            ELSE 'Não'
       END                              AS [Compatível BitLocker]

FROM v_R_System               rs
JOIN v_GS_COMPUTER_SYSTEM     cs   ON cs.ResourceID  = rs.ResourceID
JOIN v_GS_OPERATING_SYSTEM    os   ON os.ResourceID  = rs.ResourceID

-- TPM é opcional (algumas máquinas não reportam)
LEFT JOIN v_GS_TPM            tpm  ON tpm.ResourceID = rs.ResourceID

-- Filtros opcionais: descomente se desejar
-- WHERE rs.Client0 = 1 AND rs.Obsolete0 = 0

ORDER BY cs.Model0;
