/*
Найти всех сотрудников, подчиняющихся Ивану Иванову (с EmployeeID = 1), включая их подчиненных и подчиненных подчиненных, а также самого Ивана Иванова. Для каждого сотрудника вывести следующую информацию:

EmployeeID: идентификатор сотрудника.
Имя сотрудника.
ManagerID: Идентификатор менеджера.
Название отдела, к которому он принадлежит.
Название роли, которую он занимает.
Название проектов, к которым он относится (если есть, конкатенированные в одном столбце через запятую).
Название задач, назначенных этому сотруднику (если есть, конкатенированные в одном столбце через запятую).
Если у сотрудника нет назначенных проектов или задач, отобразить NULL.
Требования:

Рекурсивно извлечь всех подчиненных сотрудников Ивана Иванова и их подчиненных.
Для каждого сотрудника отобразить информацию из всех таблиц.
Результаты должны быть отсортированы по имени сотрудника.
*/

WITH RECURSIVE employee_hierarchy AS (
    SELECT 
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID,
        0 AS level
    FROM Employees e
    WHERE e.EmployeeID = 1
    
    UNION ALL
    
    SELECT 
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID,
        eh.level + 1
    FROM Employees e
    INNER JOIN employee_hierarchy eh ON e.ManagerID = eh.EmployeeID
    WHERE eh.level < 10
),
employee_projects AS (
    SELECT 
        eh.EmployeeID,
        GROUP_CONCAT(DISTINCT p.ProjectName SEPARATOR ', ') AS project_names
    FROM employee_hierarchy eh
    LEFT JOIN Tasks t ON eh.EmployeeID = t.AssignedTo
    LEFT JOIN Projects p ON t.ProjectID = p.ProjectID
    GROUP BY eh.EmployeeID
),
employee_tasks AS (
    SELECT 
        eh.EmployeeID,
        GROUP_CONCAT(DISTINCT t.TaskName SEPARATOR ', ') AS task_names
    FROM employee_hierarchy eh
    LEFT JOIN Tasks t ON eh.EmployeeID = t.AssignedTo
    GROUP BY eh.EmployeeID
)
SELECT 
    eh.EmployeeID,
    eh.Name,
    eh.ManagerID,
    d.DepartmentName,
    r.RoleName,
    CASE 
        WHEN ep.project_names IS NOT NULL THEN ep.project_names
        ELSE NULL
    END AS projects,
    CASE 
        WHEN et.task_names IS NOT NULL THEN et.task_names
        ELSE NULL
    END AS tasks
FROM employee_hierarchy eh
LEFT JOIN Departments d ON eh.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON eh.RoleID = r.RoleID
LEFT JOIN employee_projects ep ON eh.EmployeeID = ep.EmployeeID
LEFT JOIN employee_tasks et ON eh.EmployeeID = et.EmployeeID
ORDER BY eh.Name ASC;
