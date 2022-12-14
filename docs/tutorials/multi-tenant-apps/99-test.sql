SELECT run_command_on_workers('show ssl');

SELECT campaigns.id, campaigns.name, campaigns.monthly_budget,
    sum(impressions_count) as total_impressions, sum(clicks_count) as total_clicks
FROM ads, campaigns
WHERE ads.company_id = campaigns.company_id
        AND campaigns.company_id = 5
        AND campaigns.state = 'running'
GROUP BY campaigns.id, campaigns.name, campaigns.monthly_budget
ORDER BY total_impressions, total_clicks;
