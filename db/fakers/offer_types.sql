INSERT INTO `offer_types` (`id`, `name`, `name_ch`, `created_at`, `updated_at`, `api_filter`, `offer_name`, `running`, `parlay`)
VALUES
	(1,'point','讓球','2017-01-16 12:37:35','2017-01-20 14:45:44',NULL,'point',0,0),
	(2,'ou','大小','2017-01-16 12:37:35','2017-01-20 14:45:44',NULL,'ou',0,0),
	(3,'ml','獨贏','2017-01-16 12:37:35','2017-01-20 14:45:44',NULL,'ml',0,0),
	(4,'odd_even','單雙','2017-01-16 12:37:35','2017-01-20 14:45:44',NULL,'odd_even',0,0),
	(5,'running_point','走地讓球','2017-01-16 12:37:35','2017-01-20 14:45:44',NULL,'point',1,0),
	(6,'running_ou','走地大小','2017-01-16 12:37:35','2017-01-20 14:45:45',NULL,'ou',1,0),
	(7,'correct_score','波膽','2017-01-16 12:37:35','2017-01-20 14:46:20',NULL,NULL,0,0),
	(8,'total_scores','總入球','2017-01-16 12:37:35','2017-01-20 14:46:20',NULL,NULL,0,0),
	(9,'full_half','全半場','2017-01-16 12:37:36','2017-01-20 14:46:20',NULL,NULL,0,0),
	(10,'parlay_point','讓分過關','2017-01-16 12:37:36','2017-01-20 14:45:45',NULL,NULL,0,0),
	(11,'parlay_complex','綜合過關','2017-01-16 12:37:36','2017-01-20 14:46:21',NULL,NULL,0,1),
	(12,'parlay_standard','標準過關','2017-01-16 12:37:36','2017-01-20 14:46:21',NULL,NULL,0,0),
	(13,'all','全部','2017-01-16 12:37:36','2017-01-20 14:46:21',NULL,NULL,0,0),
	(14,'running_odd_even','走地單雙','2017-01-16 12:37:36','2017-01-20 14:45:46',NULL,'odd_even',1,0),
	(15,'one_win','一輸二贏','2017-01-16 12:37:36','2017-01-20 14:45:46',NULL,'one_win',0,0),
	(16,'three_way','三路','2017-01-16 12:37:36','2017-01-20 14:45:48',NULL,'three_way',0,0),
	(17,'running_ml','走地獨贏','2017-01-16 12:37:36','2017-01-20 14:45:48',NULL,'ml',1,0),
	(18,'running_correct_score','走地波膽','2017-01-16 12:37:36','2017-01-20 14:46:21',NULL,NULL,1,0),
	(19,'running_three_way','走地三路','2017-01-16 12:37:36','2017-01-20 14:45:48',NULL,'three_way',1,0),
	(20,'running_one_win','走地一輸二贏','2017-01-16 12:37:36','2017-01-20 14:45:48',NULL,'one_win',1,0);