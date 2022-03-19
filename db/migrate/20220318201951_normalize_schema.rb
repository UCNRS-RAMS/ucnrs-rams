class NormalizeSchema < ActiveRecord::Migration[6.1]
  def up
    execute(<<-end_sql)
      ALTER TABLE `active_storage_attachments`
      MODIFY COLUMN `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL AFTER `id`,
      MODIFY COLUMN `record_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL AFTER `name`,
      CHARACTER SET = utf8mb4, COLLATE = utf8mb4_unicode_ci;
    end_sql

    execute(<<-end_sql)
      ALTER TABLE `active_storage_blobs`
      MODIFY COLUMN `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL AFTER `id`,
      MODIFY COLUMN `filename` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL AFTER `key`,
      MODIFY COLUMN `content_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL AFTER `filename`,
      MODIFY COLUMN `metadata` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL AFTER `content_type`,
      MODIFY COLUMN `checksum` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL AFTER `byte_size`,
      MODIFY COLUMN `service_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL AFTER `created_at`,
      CHARACTER SET = utf8mb4, COLLATE = utf8mb4_unicode_ci;
    end_sql

    execute(<<-end_sql)
      ALTER TABLE `logs`
      MODIFY COLUMN `text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL AFTER `id`,
      MODIFY COLUMN `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL AFTER `text`,
      CHARACTER SET = utf8mb4, COLLATE = utf8mb4_unicode_ci;
    end_sql

    execute(<<-end_sql)
      ALTER TABLE `logx`
      MODIFY COLUMN `metadata` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL AFTER `action`,
      MODIFY COLUMN `log` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL AFTER `metadata`,
      MODIFY COLUMN `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL AFTER `log`,
      MODIFY COLUMN `record_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL AFTER `comment`,
      CHARACTER SET = utf8mb4, COLLATE = utf8mb4_unicode_ci;
    end_sql

    execute(<<-end_sql)
      ALTER TABLE `project_permit_answers` CHARACTER SET = utf8mb4, COLLATE = utf8mb4_unicode_ci;
    end_sql

    execute(<<-end_sql)
      ALTER TABLE `projects`
      MODIFY COLUMN `method_study_area` varchar(10000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL AFTER `MethodAnchorCollectShoreline`,
      MODIFY COLUMN `ApplicationPassword` char(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'DEPRECATED' AFTER `ProjectChanges`;
    end_sql

    execute(<<-end_sql)
      ALTER TABLE `rams_options`
      MODIFY COLUMN `option_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL AFTER `id`,
      MODIFY COLUMN `option_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL AFTER `option_name`,
      CHARACTER SET = utf8mb4, COLLATE = utf8mb4_unicode_ci;
    end_sql

    execute(<<-end_sql)
      ALTER TABLE `reserve_addendums`
      MODIFY COLUMN `url_link` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL AFTER `sort_order`,
      MODIFY COLUMN `url_text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL AFTER `url_link`,
      MODIFY COLUMN `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL AFTER `url_text`,
      MODIFY COLUMN `info_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL AFTER `subject`,
      MODIFY COLUMN `info_format` enum('text','html','embed_code','image') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'text' AFTER `info_text`,
      CHARACTER SET = utf8mb4, COLLATE = utf8mb4_unicode_ci;
    end_sql

    execute(<<-end_sql)
      ALTER TABLE `reserve_settings` CHARACTER SET = utf8mb4, COLLATE = utf8mb4_unicode_ci;
    end_sql

    execute(<<-end_sql)
      ALTER TABLE `waivers`
      MODIFY COLUMN `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL AFTER `id`,
      MODIFY COLUMN `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL AFTER `name`,
      MODIFY COLUMN `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL AFTER `description`,
      MODIFY COLUMN `url_type` enum('link','pdf') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'link' AFTER `updated_at`,
      CHARACTER SET = utf8mb4, COLLATE = utf8mb4_unicode_ci;
    end_sql

    execute(<<-end_sql)
      ALTER TABLE `ucnrs_rams_development`.`application_permit_answers` 
      MODIFY COLUMN `vertebrates` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL AFTER `expires_on`;
    end_sql
  end
end
