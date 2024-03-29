local http = require("coro-http")
local json = require("json")

local function validateInputTypes(input)
    if type(input) ~= "table" then return nil end

    local matchesTypes = true
    for _, each in ipairs(input) do
        local validType = false
        for _, etype in ipairs(each[2]) do
            if type(each[1]) == etype then
                validType = true
                break
            end
        end
        if not validType then
            matchesTypes = false
            break
        end
    end

    return matchesTypes
end

local edulink = {}

edulink.school = nil
edulink.authentication = nil
edulink.learner = nil

function edulink.rawrequest(request_type, provisionUrl, method, headers, params)
    if not validateInputTypes({
        {request_type, {"string"}},
        {provisionUrl, {"string"}},
        {method, {"string"}},
        {headers, {"table", "nil"}},
        {params, {"table", "nil"}},
    }) then return nil, "Required parameters were not supplied" end
    --if not request_type or not method then return nil, "Required parameters not supplied." end

    if not headers then headers = {} end
    if not params then params = {} end

    local payload = {}
    payload.id = "1"
    payload.jsonrpc = "2.0"
    payload.method = method
    payload.params = params
    encoded_payload = json.encode(payload)

    headers["Content-Type"] = "application/json;charset=UTF-8"
    headers["Content-Length"] = #encoded_payload
    headers["X-Api-Method"] = method

    if edulink.authentication then
        headers.Authorization = "Bearer ".. edulink.authentication
    end

    local formattedHeaders = {}
    for i,v in pairs(headers) do
        table.insert(formattedHeaders, {i, v})
    end

    local response_headers, body = http.request(request_type, provisionUrl .."?method=".. method, formattedHeaders, encoded_payload)

    body = json.decode(body)
    if not body or not body.result.success then
        errmsg = body.result.error or "No error provided by EduLink API"
        local err = "Error in request with HTTP ".. response_headers.code .." ".. response_headers.reason ..": ".. errmsg
        error(err)
        return nil, err
    end

    return body.result, true
end

-- school_postcode: REQUIRED string
-- retrieve provision / school details when provided with an institution postcode (required)
-- dont even ask why the edulink api handles your sensitive info in plain, clear text...
function edulink.provision(school_postcode)
    if not validateInputTypes({
        {school_postcode, {"string"}}
    }) then return nil, "Required parameters were not supplied" end

    local result, err = edulink.rawrequest("POST", "https://provisioning.edulinkone.com/", "School.FromCode", nil, {
        code = school_postcode
    })

    edulink.school = result.school

    return result.school, err
end

-- username: REQUIRED string, password: REQUIRED string, school_postcode: OPTIONAL string
-- authenticate (log in) with the specified username, password and postcode (if not provided, then the postcode from the previous provision request will be used)
function edulink.authenticate(username, password, school_postcode)
    if not validateInputTypes({
        {username, {"string"}},
        {password, {"string"}},
        {school_postcode, {"string", "nil"}}
    }) then return nil, "Required parameters were not supplied" end
    if (not school_postcode and not edulink.school) then return nil, "Required parameters were not supplied" end

    edulink.school = edulink.provision(school_postcode) or edulink.school

    local result, err = edulink.rawrequest("POST", edulink.school.server, "EduLink.Login", nil, {
        establishment_id = edulink.school.school_id,
        username = username,
        password = password,
        from_app = false
    })

    edulink.authentication = result.authtoken
    edulink.learner = result.user

    print("lua-edulink: Authenticated as ".. result.user.forename)

    return result.authtoken, true
end

-- date: OPTIONAL string or number, learner_id: OPTIONAL number
-- Return an array of all lessons on a specified date (either unix time number or string in the format of YYYY-MM-DD) and for a specified learner (or the learner that was used to initially authenticate)
function edulink.timetable(date, proximity, learner_id)
    if not validateInputTypes({
        {date, {"string", "number"}},
        {proximity, {"string", "nil"}},
        {learner_id, {"number", "nil"}},
    }) then return nil, "Required parameters were not supplied" end

    date = date or os.time()
    if type(date) == "number" then date = os.date("%Y-%m-%d", date) end
    proximity = proximity or "close"
    if proximity ~= "exact" or proximity ~= "close" then return nil, "Required parameters were not supplied"
    learner_id = learner_id or edulink.learner.id

    local result, err = edulink.rawrequest("POST", edulink.school.server, "EduLink.Timetable", nil, {
        learner_id = edulink.learner.id,
        date = date
    })

    local found = nil
    for weekIndex, week in pairs(result.weeks) do
        for dayIndex, day in pairs(week.days) do
            if day.date == date then
                found = day.lessons
            end
        end
    end

    if not found then return nil, "Failed to find lessons on that day. Maybe there are no lessons?" end

    return found, true
end

function edulink.homework(page, rat)
    local result, err = edulink.rawrequest("POST", edulink.school.server, "EduLink.Homework", nil, {
        format = 2
    })


end

return edulink