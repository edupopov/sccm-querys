/*
    Contagem de dispositivos Windows por versão (por BuildNumber)
    Banco: CM_BRF
    Views: v_R_System (rs), v_GS_OPERATING_SYSTEM (os)
    Autor: Eduardo Popovici - Comentado e organizado pelo Copilot

    Melhorias:
    - Converte BuildNumber para INT (TRY_CONVERT) p/ comparações numéricas.
    - Mapeamento centralizado em "VALUES" (fácil manutenção).
    - OUTER APPLY para resolver rótulo 1x por linha.
    - Pré-filtro em famílias (Win7/8.1/10/11).
    - Fallback claro para builds não mapeados.
    - Ordenação natural por recência via PesoOrdenacao.
    - Inclui Windows 11 25H2 (família 26200.xxxx).
*/

;WITH Base AS (
    SELECT
        rs.ResourceID,
        os.Caption0,
        TRY_CONVERT(int, os.BuildNumber0) AS BuildNumberInt,
        os.BuildNumber0
    FROM v_R_System AS rs WITH (NOLOCK)
    JOIN v_GS_OPERATING_SYSTEM AS os WITH (NOLOCK)
        ON os.ResourceID = rs.ResourceID
    WHERE
        rs.Obsolete0 = 0
        AND rs.Client0 = 1
        AND (
            os.Caption0 LIKE 'Microsoft Windows 7%' OR
            os.Caption0 LIKE 'Microsoft Windows 8.1%' OR
            os.Caption0 LIKE 'Microsoft Windows 10%' OR
            os.Caption0 LIKE 'Microsoft Windows 11%'
        )
),

/* Mapeamento de versões com PesoOrdenacao:
   - Quanto MAIOR o peso, mais “novo”/prioritário.
*/
MapVersao AS (
    SELECT
        v.PesoOrdenacao,
        v.Familia,
        v.InicioFaixa,
        v.FimFaixa,
        v.Rotulo
    FROM (VALUES

        /* ----------------------- Windows 11 ----------------------- */
        (1000, 'Windows 11', 26200, 26299, 'Windows 11 25H2 (26200)'),
        ( 900, 'Windows 11', 26100, 26199, 'Windows 11 24H2 (26100)'),
        ( 800, 'Windows 11', 22631, 22631, 'Windows 11 23H2 (22631)'),
        ( 700, 'Windows 11', 22621, 22621, 'Windows 11 22H2 (22621)'),
        ( 600, 'Windows 11', 22000, 22000, 'Windows 11 21H2 (22000)'),

        /* ----------------------- Windows 10 ----------------------- */
        ( 500, 'Windows 10', 19045, 19045, 'Windows 10 22H2 (19045)'),
        ( 490, 'Windows 10', 19044, 19044, 'Windows 10 21H2 (19044)'),
        ( 480, 'Windows 10', 19043, 19043, 'Windows 10 21H1 (19043)'),
        ( 470, 'Windows 10', 19042, 19042, 'Windows 10 20H2 (19042)'),
        ( 460, 'Windows 10', 19041, 19041, 'Windows 10 2004 (19041)'),
        ( 450, 'Windows 10', 18363, 18363, 'Windows 10 1909 (18363)'),
        ( 440, 'Windows 10', 18362, 18362, 'Windows 10 1903 (18362)'),
        ( 430, 'Windows 10', 17763, 17763, 'Windows 10 1809 (17763)'),
        ( 420, 'Windows 10', 17134, 17134, 'Windows 10 1803 (17134)'),
        ( 410, 'Windows 10', 16299, 16299, 'Windows 10 1709 (16299)'),
        ( 400, 'Windows 10', 15063, 15063, 'Windows 10 1703 (15063)'),
        ( 390, 'Windows 10', 14393, 14393, 'Windows 10 1607 (14393)'),
        ( 380, 'Windows 10', 10586, 10586, 'Windows 10 1511 (10586)'),
        ( 370, 'Windows 10', 10240, 10240, 'Windows 10 1507 (10240)')

    ) AS v(PesoOrdenacao, Familia, InicioFaixa, FimFaixa, Rotulo)
),

Resolvido AS (
    SELECT
        b.ResourceID,
        CASE
            WHEN b.Caption0 LIKE 'Microsoft Windows 11%' THEN 'Windows 11'
            WHEN b.Caption0 LIKE 'Microsoft Windows 10%' THEN 'Windows 10'
            WHEN b.Caption0 LIKE 'Microsoft Windows 8.1%' THEN 'Windows 8.1'
            WHEN b.Caption0 LIKE 'Microsoft Windows 7%' THEN 'Windows 7'
            ELSE REPLACE(b.Caption0, 'Microsoft ', '')
        END AS Familia,
        b.BuildNumberInt,
        b.BuildNumber0,
        b.Caption0
    FROM Base AS b
),

Aplicado AS (
    SELECT
        r.ResourceID,
        COALESCE(
            m.Rotulo,
            CASE
                WHEN r.Familia IN ('Windows 10','Windows 11') AND r.BuildNumber0 IS NOT NULL
                    THEN CONCAT(r.Familia, ' (Build ', r.BuildNumber0, ')')
                WHEN r.Familia IN ('Windows 10','Windows 11') AND r.BuildNumber0 IS NULL
                    THEN CONCAT(r.Familia, ' (Build desconhecida)')
                ELSE r.Familia
            END
        ) AS VersaoWindows,
        COALESCE(m.PesoOrdenacao, 0) AS PesoOrdenacao
    FROM Resolvido AS r
    OUTER APPLY (
        SELECT TOP (1)
            mv.Rotulo,
            mv.PesoOrdenacao
        FROM MapVersao AS mv
        WHERE
            mv.Familia = r.Familia
            AND r.BuildNumberInt IS NOT NULL
            AND r.BuildNumberInt BETWEEN mv.InicioFaixa AND mv.FimFaixa
        ORDER BY mv.PesoOrdenacao DESC
    ) AS m
)

SELECT
    a.VersaoWindows,
    COUNT(DISTINCT a.ResourceID) AS Qtde
FROM Aplicado AS a
GROUP BY a.VersaoWindows
ORDER BY
    MAX(a.PesoOrdenacao) DESC,
    a.VersaoWindows;
