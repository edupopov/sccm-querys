SELECT
    rs.Name0 AS Host
FROM v_R_System rs
WHERE rs.Client0 = 1
  AND rs.Obsolete0 = 0
  AND NOT EXISTS (
        SELECT 1
        FROM v_Add_Remove_Programs arp
        WHERE arp.ResourceID = rs.ResourceID
          AND (
                arp.DisplayName0 = 'CrowdStrike Windows Sensor'
                OR arp.DisplayName0 LIKE 'CrowdStrike%Sensor%'
              )
      )
ORDER BY rs.Name0;
