-- 参考
-- https://qiita.com/setsuna82001/items/e742338eb93e3a48ba46
-- https://hit.hateblo.jp/entry/mysql/concat-pipe
-- https://www.wakuwakubank.com/posts/332-mysql-sql-function-string/
-- @TODO えらーハンドリングしないといけない

DROP PROCEDURE popApiIdFromModule;

DELIMITER //
CREATE PROCEDURE popApiIdFromModule(IN targetApiId INT)
BEGIN
-- 対象モジュール
    DECLARE moduleName VARCHAR(10);
-- 対象モジュールに設定されているAPI文字列 修正前
    DECLARE beforApiIds VARCHAR(10);
-- 対象モジュールに設定されているAPI文字列 修正後
    DECLARE afterApiIds VARCHAR(10);
-- 対象モジュールのセレクトカーソル
    DECLARE moduleCur CURSOR FOR
        SELECT
            module_name,
            api_ids
        FROM
            module
        WHERE
            concat(',', api_Ids, ',') LIKE concat('%,', targetApiId, ',%');
--            api_ids REGEXP concat(apiId, '|', apiId, ',|,', apiId, '|,', apiId, ',')
--            AND api_ids NOT REGEXP concat('[1-9]', apiId)
--            AND api_ids NOT REGEXP concat(apiId, '[0-9]')
--            AND api_ids NOT REGEXP concat('[1-9]',apiId,'[0-9]');

-- 対象APIの指定を削除 --
-- カーソル開けごま！
    OPEN moduleCur;
    FETCH NEXT FROM moduleCur
    INTO moduleName, beforApiIds;
    WHILE @@FETCH_STATUS = 0 -- @TODO MySQLで使えない？
        BEGIN
            -- 更新前に確認
            SELECT concat('brfore module::', moduleName , 'apiIds::', beforApiIds);
            SET afterApiIds = REPLACE(CONCAT(‘,’, beforApiIds, ’,’), CONCAT(',', targetApiId, ','), ','); -- @TODO 動く？ ,削除しないといけない
            -- 対象モジュールのAPI利用管理文字列を更新
            UPDATE
                module
            SET
                api_ids=afterApiIds
            WHERE
                module_name=moduleName;
            -- 更新後の確認
            SELECT concat(`after module::` moduleName + ` apiIds::` + apiIds);
            -- 次の行の情報に更新
            FETCH NEXT FROM moduleCur
        	INTO moduleName, apiIds;
        END
-- カーソルありがとう！
    CLOSE moduleCur;
    DEALLOCATE moduleCur;
----
END
//
DELIMITER ;

