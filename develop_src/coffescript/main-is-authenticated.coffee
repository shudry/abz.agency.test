$ = jQuery

class AJAXEmployeesManager

    shownFirstWorkersId = {}

    constructor: (@firstCount, @secondCount) ->

    getEmployee: (url, requestDone) ->
        thisContext = this
        request = $.ajax 
            url: url
            type: "GET"

        request.done requestDone
        request.fail (jqXHR, textStatus, errorThrown) ->
            #error request AJAX
            thisContext.showErrorAlert errorThrown


    appendElementToDOM = (element, id) ->
        id_element = if id then "employee-#{id}-#{element.id}" else "employee-id-#{element.id}"
        html = """
            <div class="employee" id="#{id_element}">
                <div class="row">
                    <div class="col-md-1 employee-image"><i class="fas fa-user-tie fa-2x"></i></div>
                    <div class="col-md-3">
                      <p>#{element.name}</p>
                    </div>
                    <div class="col-md-2">
                      <p>#{element.work_position}</p>
                    </div>
                    <div class="col-md-2">
                      <p>#{element.wage}</p>
                    </div>
                    <div class="col-md-2">
                      <p>#{element.date_join}</p>
                    </div>
                    <div class="col-md-2">
                      <p>#{element.id}</p>
                    </div>
                </div>
            </div>
        """

    appendElementLoadMore = (element_chief) ->
        html = """
            <div class="employee load-more-empl" id="employee-load-more-#{element_chief}">
                <div class="row justify-content-md-center">
                    <div class="col-md-auto">
                        <a href="#load-more" class="employee-load-more-link btn btn-default" id="#{element_chief}">Загрузити ще ...</a>
                    </div>
                </div>
            </div>
        """


    showFirstHierarchy: (count, urlNext, isSearchResult=false) ->
        url = urlNext or "/employee/withoutchief/?limit=#{count}"
        thisContext = this

        @getEmployee url, (data, textStatus, jqXHR) ->
            if data.results or data.count > 0 or not data.next
                $("#employee-load-more-first-loads").remove()

            if !isSearchResult
                #Show warning alerts "employees not found"
                if Object.keys(shownFirstWorkersId).length == 0
                    if not data.results or data.count == 0
                        thisContext.showNotFoundAlert()
            else
                if not data.results or data.count == 0
                    thisContext.showNotFoundAlert()

            for element in data.results
                if !isSearchResult
                    if not shownFirstWorkersId[element.id]
                        shownFirstWorkersId[element.id] = {
                            self: element,
                            subordinates: {}
                        }
                        $(".container-workers").append(appendElementToDOM element)
                    
                        #Initialization show subordinates(second hierarchy)
                        thisContext.showSecondHierarchy element.id, null, thisContext.secondCount                
                else
                    # Show search results
                    $(".container-workers").append(appendElementToDOM element, "search-result")
                    #thisContext.showSecondHierarchy element.id, null, thisContext.secondCount

            if data.next
                $(".container-workers").append(appendElementLoadMore "first-loads")
                $("#employee-load-more-first-loads").find("a").click (e) ->
                    thisContext.showFirstHierarchy count, data.next, isSearchResult


    showSecondHierarchy: (elementID, urlNext, count, doUseGlobalArray=true) ->
        url = urlNext or "/employee/#{elementID}/subordinates/?limit=#{count}"
        thisContext = this

        @getEmployee url, (data, textStatus, jqXHR) ->
            if data.results or data.count > 0 or not data.next
                $("#employee-load-more-#{elementID}").remove()
            
            # Append employees to chief
            for employee in data.results
                if doUseGlobalArray
                    if not shownFirstWorkersId[employee.chief].subordinates[employee.id]
                        shownFirstWorkersId[employee.chief].subordinates[employee.id] = employee
                        $("#employee-id-#{employee.chief}").append(appendElementToDOM employee)
                else
                    $("#employee-id-#{elementID}").append(appendElementToDOM employee)

            if data.next
                $("#employee-id-#{elementID}").append(appendElementLoadMore elementID)
                $("#employee-load-more-#{elementID}").find("a").click (e) ->
                    thisContext.showSecondHierarchy e.target.id, data.next, thisContext.secondCount, doUseGlobalArray


    hideAllEmployeesInContainer: () ->
        for element in Object.keys(shownFirstWorkersId)
            $("#employee-id-#{element}").css(display: "none")
        $("#employee-load-more-first-loads").css(display: "none")

    showAllEmployeesInContainer: () ->
        @clearContainer()

        for element in Object.keys(shownFirstWorkersId)
            $("#employee-id-#{element}").css(display: "block")
        $("#employee-load-more-first-loads").css(display: "block")


    showNotFoundAlert: () ->
        @clearContainer()

        $('#not-found-employees-warning').css(display: "block")


    hideNotFoundAlert: () ->
        $('#not-found-employees-warning').css(display: "none")

    showErrorAlert: (errorText) ->
        @clearContainer()

        $('#alert_server_error').css(display: "block")
        $('#alert_server_error #error_message').text(errorText)


    hideErrorAlert: () ->
        $('#alert_server_error').css(display: "none")

    removeSearchResults: () ->
        $('[id^="employee-search-result-"]').remove()

    clearContainer: () ->
        # Remove search results and hide all components
        @removeSearchResults()
        @hideNotFoundAlert()
        @hideErrorAlert()
        @hideAllEmployeesInContainer()

    showEmployees: () ->
        @showFirstHierarchy @firstCount

    getListWorkers: () ->
        return shownFirstWorkersId




$(document).ready ->
    managerEmployees = new AJAXEmployeesManager 40, 10
    managerEmployees.showEmployees()


    delay = (callback, ms=800) ->
        timer = 0;
        return () ->
            context = this
            args = arguments
            clearTimeout timer

            callbackRet = () ->
                callback.apply context, args

            timer = setTimeout callbackRet, ms || 0


    appendSpinner = (inputId) ->
        $(inputId).each () ->
            $(this).attr "class", "#{$(this).attr 'class'} width-input-append-spinner"
        $('<i class="fas fa-cog fa-spin"></i>').insertAfter inputId


    removeSpinner = (inputId) ->
        if $(inputId).next().is("i.fa-spin")
            $(inputId).removeClass(
                "width-input-append-spinner"
                ).next().remove()


    replaceSpaces = (element) ->
        resultString = ''
        for i in element.split(' ')
            if i != ''
                resultString += i + ' '
        return resultString.slice(0, -1)


    normalizeSendData = (data) ->
        if "|" in data
            resultData = data.split("|")

            for searchStrElem, index in resultData
                resultData[index] = replaceSpaces(searchStrElem)

            return resultData
        else
            return [replaceSpaces(data)]


    sendSearchBy = () ->
        byNameData = normalizeSendData($('#search-by-name-field').val())
        byWorkPositionData = normalizeSendData($('#search-by-work-position-field').val())
        byWageData = normalizeSendData($('#search-by-wage-field').val())

        requestSearchFieldsData = ''
        
        if byNameData.length > 0 and byNameData[0] != ''
            requestSearchFieldsData += 'name__icontains=' + byNameData.join() + '|'
    
        if byWorkPositionData.length > 0 and byWorkPositionData[0] != ''
            requestSearchFieldsData += 'work_position__icontains=' + byWorkPositionData.join() + '|'

        if byWageData.length > 0 and byWageData[0] != ''
            requestSearchFieldsData += 'wage=' + byWageData.join() + '|'
        
        if requestSearchFieldsData.length == 0
            return managerEmployees.showAllEmployeesInContainer()

        requestSearchFieldsData.slice(0, -1)

        requestData = encodeURIComponent(requestSearchFieldsData)
        limit = 20

        url = "/employee/search/?limit=#{limit}&data=#{requestData}"
        managerEmployees.clearContainer()
        managerEmployees.showFirstHierarchy(20, url, true)


    functionSearchBy = (e) ->
        data = e.currentTarget.value

        appendSpinner(e.currentTarget)
        
        sendSearchBy()

        functionTimeout = () ->
            removeSpinner(e.currentTarget)
        setTimeout functionTimeout, 1000


    $('#search-by-name-field').keyup delay functionSearchBy #Search by name
    $('#search-by-work-position-field').keyup delay functionSearchBy #Search by work position
    $('#search-by-wage-field').keyup delay functionSearchBy #Search by wage
