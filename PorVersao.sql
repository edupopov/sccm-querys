/* Contagem de dispositivos Windows por versão (conforme BuildNumber)

   Banco: CM_BRF

   Views: v_R_System, v_GS_OPERATING_SYSTEM

*/

  

SELECT

    CASE

        /* Windows 11 */

        WHEN os.Caption0 LIKE 'Microsoft Windows 11%' AND os.BuildNumber0 = '26100' THEN 'Windows 11 24H2 (26100)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 11%' AND os.BuildNumber0 = '22631' THEN 'Windows 11 23H2 (22631)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 11%' AND os.BuildNumber0 = '22621' THEN 'Windows 11 22H2 (22621)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 11%' AND os.BuildNumber0 = '22000' THEN 'Windows 11 21H2 (22000)'

  

        /* Windows 10 */

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '19045' THEN 'Windows 10 22H2 (19045)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '19044' THEN 'Windows 10 21H2 (19044)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '19043' THEN 'Windows 10 21H1 (19043)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '19042' THEN 'Windows 10 20H2 (19042)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '19041' THEN 'Windows 10 2004 (19041)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '18363' THEN 'Windows 10 1909 (18363)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '18362' THEN 'Windows 10 1903 (18362)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '17763' THEN 'Windows 10 1809 (17763)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '17134' THEN 'Windows 10 1803 (17134)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '16299' THEN 'Windows 10 1709 (16299)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '15063' THEN 'Windows 10 1703 (15063)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '14393' THEN 'Windows 10 1607 (14393)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '10586' THEN 'Windows 10 1511 (10586)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '10240' THEN 'Windows 10 1507 (10240)'

  

        /* Windows 7 / 8.1 (caso existam) */

        WHEN os.Caption0 LIKE 'Microsoft Windows 7%' THEN 'Windows 7'

        WHEN os.Caption0 LIKE 'Microsoft Windows 8.1%' THEN 'Windows 8.1'

  

        /* Fallback: mostra família e build quando não mapeado acima */

        WHEN os.Caption0 LIKE 'Microsoft Windows 11%' THEN CONCAT('Windows 11 (Build ', os.BuildNumber0, ')')

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' THEN CONCAT('Windows 10 (Build ', os.BuildNumber0, ')')

        ELSE REPLACE(os.Caption0, 'Microsoft ', '')  -- outros Windows, Server, etc.

    END AS VersaoWindows,

    COUNT(DISTINCT rs.ResourceID) AS Qtde

FROM v_R_System AS rs

JOIN v_GS_OPERATING_SYSTEM AS os

  ON os.ResourceID = rs.ResourceID

WHERE rs.Obsolete0 = 0

  AND rs.Client0   = 1

  AND (

        os.Caption0 LIKE 'Microsoft Windows 7%'  OR

        os.Caption0 LIKE 'Microsoft Windows 8.1%' OR

        os.Caption0 LIKE 'Microsoft Windows 10%' OR

        os.Caption0 LIKE 'Microsoft Windows 11%'

      )

GROUP BY

    CASE

        WHEN os.Caption0 LIKE 'Microsoft Windows 11%' AND os.BuildNumber0 = '26100' THEN 'Windows 11 24H2 (26100)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 11%' AND os.BuildNumber0 = '22631' THEN 'Windows 11 23H2 (22631)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 11%' AND os.BuildNumber0 = '22621' THEN 'Windows 11 22H2 (22621)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 11%' AND os.BuildNumber0 = '22000' THEN 'Windows 11 21H2 (22000)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '19045' THEN 'Windows 10 22H2 (19045)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '19044' THEN 'Windows 10 21H2 (19044)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '19043' THEN 'Windows 10 21H1 (19043)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '19042' THEN 'Windows 10 20H2 (19042)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '19041' THEN 'Windows 10 2004 (19041)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '18363' THEN 'Windows 10 1909 (18363)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '18362' THEN 'Windows 10 1903 (18362)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '17763' THEN 'Windows 10 1809 (17763)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '17134' THEN 'Windows 10 1803 (17134)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '16299' THEN 'Windows 10 1709 (16299)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '15063' THEN 'Windows 10 1703 (15063)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '14393' THEN 'Windows 10 1607 (14393)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '10586' THEN 'Windows 10 1511 (10586)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' AND os.BuildNumber0 = '10240' THEN 'Windows 10 1507 (10240)'

        WHEN os.Caption0 LIKE 'Microsoft Windows 7%'   THEN 'Windows 7'

        WHEN os.Caption0 LIKE 'Microsoft Windows 8.1%' THEN 'Windows 8.1'

        WHEN os.Caption0 LIKE 'Microsoft Windows 11%' THEN CONCAT('Windows 11 (Build ', os.BuildNumber0, ')')

        WHEN os.Caption0 LIKE 'Microsoft Windows 10%' THEN CONCAT('Windows 10 (Build ', os.BuildNumber0, ')')

        ELSE REPLACE(os.Caption0, 'Microsoft ', '')

    END

ORDER BY Qtde DESC, VersaoWindows;
