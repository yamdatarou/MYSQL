-- 参考
-- https://qiita.com/setsuna82001/items/e742338eb93e3a48ba46
-- https://hit.hateblo.jp/entry/mysql/concat-pipe
-- https://www.wakuwakubank.com/posts/332-mysql-sql-function-string/
-- @TODO えらーハンドリングしないといけない

DROP PROCEDURE popApiIdFromModule;

DELIMITER //
CREATE PROCEDURE popApiIdFromModule(IN targetApiId INT)
BEGIN
    -- ハンドラで利用する変数 v_done を宣言
    DECLARE v_done INT DEFAULT 0;
    -- 対象モジュール
    DECLARE moduleName VARCHAR(10);
    -- 対象モジュールに設定されているAPI文字列 修正前
    DECLARE beforApiIds VARCHAR(10);
    -- 対象モジュールに設定されているAPI文字列 修正後
    DECLARE afterApiIds VARCHAR(10);
    DECLARE tmpAfterApiIds VARCHAR(10);
    -- 対象モジュールのセレクトカーソル
    DECLARE moduleCur CURSOR FOR
        SELECT
            module_name,
            api_ids
        FROM
            module
        WHERE
            concat(',', api_Ids, ',') LIKE concat('%,', targetApiId, ',%');
    -- SQLステートが02000の場合にv_doneを1にするハンドラを宣言
    DECLARE continue handler FOR sqlstate '02000' SET v_done = 1;

    OPEN moduleCur;
    FETCH NEXT FROM moduleCur INTO moduleName, beforApiIds;
    WHILE v_done != 1 DO
        BEGIN
            SELECT moduleName;
            SET tmpAfterApiIds = REPLACE(CONCAT(',', beforApiIds, ','), CONCAT(',', targetApiId, ','), ',');
            SET afterApiIds = TRIM(',' FROM tmpAfterApiIds);
            FETCH NEXT FROM moduleCur INTO moduleName, beforApiIds;
        END;
    END WHILE;
    CLOSE moduleCur;
END
//
DELIMITER ;

