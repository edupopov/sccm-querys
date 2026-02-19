SELECT

    rs.Name0                          AS Host,

    cs.Manufacturer0                  AS Vendor,

    cs.Model0                         AS Modelo,

    os.Caption0                       AS SistemaOperacional,

    os.BuildNumber0                   AS Build,

  

    CASE os.BuildNumber0

        WHEN '19044' THEN 'Windows 10 21H2'

        WHEN '19045' THEN 'Windows 10 22H2'

        WHEN '22621' THEN 'Windows 11 22H2'

        WHEN '22631' THEN 'Windows 11 23H2'

        WHEN '26100' THEN 'Windows 11 24H2'

        ELSE 'N/D'

    END                                AS Release,

  

    os.OSArchitecture0                AS Arquitetura,

    ws.LastHWScan                     AS UltimoInventario,

  

    ev.DriveLetter0                   AS Unidade,

    ev.ProtectionStatus0              AS Protecao,

  

    CASE ev.ProtectionStatus0

        WHEN 0 THEN 'Sem proteção'

        WHEN 1 THEN 'Protegido'

        WHEN 2 THEN 'Desconhecido'

        ELSE 'Outro'

    END                                AS StatusProtecao,

  

    tpm.SpecVersion0                  AS TPM_Spec,

    tpm.IsEnabled_InitialValue0       AS TPM_Enabled,

    tpm.IsActivated_InitialValue0     AS TPM_Activated,

    tpm.IsOwned_InitialValue0         AS TPM_Owned

  

FROM v_R_System rs

JOIN v_GS_COMPUTER_SYSTEM cs         ON cs.ResourceID = rs.ResourceID

JOIN v_GS_OPERATING_SYSTEM os        ON os.ResourceID = rs.ResourceID

LEFT JOIN v_GS_WORKSTATION_STATUS ws ON ws.ResourceID = rs.ResourceID

LEFT JOIN v_GS_TPM tpm               ON tpm.ResourceID = rs.ResourceID

LEFT JOIN v_GS_ENCRYPTABLE_VOLUME ev ON ev.ResourceID = rs.ResourceID

    AND ev.DriveLetter0 = 'C:'

  

WHERE rs.Client0 = 1

  AND rs.Obsolete0 = 0

  

ORDER BY Host;
