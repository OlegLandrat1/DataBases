/*
Найти всех сотрудников, которые занимают роль менеджера и имеют подчиненных (то есть число подчиненных больше 0). Для каждого такого сотрудника вывести следующую информацию:

EmployeeID: идентификатор сотрудника.
Имя сотрудника.
Идентификатор менеджера.
Название отдела, к которому он принадлежит.
Название роли, которую он занимает.
Название проектов, к которым он относится (если есть, конкатенированные в одном столбце).
Название задач, назначенных этому сотруднику (если есть, конкатенированные в одном столбце).
Общее количество подчиненных у каждого сотрудника (включая их подчиненных).
Если у сотрудника нет назначенных проектов или задач, отобразить NULL.
*/

WITH RECURSIVE subordinate_hierarchy AS (
    SELECT 
        e.EmployeeID,
        e.ManagerID,
        1 AS subordinate_count
    FROM Employees e
    WHERE e.ManagerID IS NOT NULL
    
    UNION ALL
    
    SELECT 
        sh.EmployeeID,
        e.ManagerID,
        sh.subordinate_count + 1
    FROM subordinate_hierarchy sh
    INNER JOIN Employees e ON sh.ManagerID = e.EmployeeID
    WHERE e.ManagerID IS NOT NULL
),
all_subordinates AS (
    SELECT 
        ManagerID,
        COUNT(DISTINCT EmployeeID) AS total_subordinates
    FROM subordinate_hierarchy
    GROUP BY ManagerID
),
manager_employees AS (
    SELECT 
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID,
        COALESCE(asu.total_subordinates, 0) AS subordinate_count
    FROM Employees e
    INNER JOIN Roles r ON e.RoleID = r.RoleID
    LEFT JOIN all_subordinates asu ON e.EmployeeID = asu.ManagerID
    WHERE r.RoleName = 'Менеджер' 
        AND COALESCE(asu.total_subordinates, 0) > 0
),
employee_projects AS (
    SELECT 
        me.EmployeeID,
        GROUP_CONCAT(DISTINCT p.ProjectName SEPARATOR ', ') AS project_names
    FROM manager_employees me
    LEFT JOIN Tasks t ON me.EmployeeID = t.AssignedTo
    LEFT JOIN Projects p ON t.ProjectID = p.ProjectID
    GROUP BY me.EmployeeID
),
employee_tasks AS (
    SELECT 
        me.EmployeeID,
        GROUP_CONCAT(DISTINCT t.TaskName SEPARATOR ', ') AS task_names
    FROM manager_employees me
    LEFT JOIN Tasks t ON me.EmployeeID = t.AssignedTo
    GROUP BY me.EmployeeID
)
SELECT 
    me.EmployeeID,
    me.Name,
    me.ManagerID,
    d.DepartmentName,
    r.RoleName,
    CASE 
        WHEN ep.project_names IS NOT NULL THEN ep.project_names
        ELSE NULL
    END AS projects,
    CASE 
        WHEN et.task_names IS NOT NULL THEN et.task_names
        ELSE NULL
    END AS tasks,
    me.subordinate_count
FROM manager_employees me
LEFT JOIN Departments d ON me.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON me.RoleID = r.RoleID
LEFT JOIN employee_projects ep ON me.EmployeeID = ep.EmployeeID
LEFT JOIN employee_tasks et ON me.EmployeeID = et.EmployeeID
ORDER BY me.Name ASC;
