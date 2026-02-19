SELECT
    rs.Name0 AS Host,
    MAX(arp.Version0) AS VersaoFalcon
FROM v_R_System rs
JOIN v_Add_Remove_Programs arp
      ON arp.ResourceID = rs.ResourceID
WHERE rs.Client0 = 1
  AND rs.Obsolete0 = 0
  AND (
        arp.DisplayName0 = 'CrowdStrike Windows Sensor'
        OR arp.DisplayName0 LIKE 'CrowdStrike%Sensor%'
      )
GROUP BY rs.Name0
ORDER BY rs.Name0;
