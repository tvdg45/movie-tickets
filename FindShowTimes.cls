public with sharing class FindShowTimes {
	
    //Variables
    public String cinema {get; set;}
    public String movieTitle {get; set;}
    public DateTime showDateTimeBeginningIn {get; set;}
    public DateTime showDateTimeEndingIn {get; set;}
    public String triggerSearch;
    
    //Create picklist of cinemas
    public List<SelectOption> getCinemaPicklist() {
        
        List<SelectOption> output = new List<SelectOption>();
        
        output.add(new SelectOption('Choose cinema', 'Choose cinema', false));
        
        try {
            
            if (Schema.SObjectType.Cinema__c.isAccessible()) {
            	
                for (Cinema__c cinemaOption: [SELECT Name FROM Cinema__c WHERE OwnerId = :UserInfo.getUserId()
                                              ORDER BY Name ASC]) {
                
                	output.add(new SelectOption(cinemaOption.Name, cinemaOption.Name, false));
            	}
            }
        } catch (Exception e) {
            
            System.debug('An expected database error has occurred: ' + e.getMessage());
        }
        
        return output;
    }
    
    public void triggerSearch() {
        
        this.triggerSearch = 'Search';
    }
    
    public String getSearchResults() {
        
        String output = '';
        String showTimes = '';
        String movies = '';
        String queryString = '';
        integer numberOfResults = 0;
        Movie__c[] eachMovie = null;

        if (this.triggerSearch == 'Search') {
        
            if (this.cinema != 'Choose cinema' || this.movieTitle != '' || !(this.movieTitle.isWhitespace()) 
                || (this.showDateTimeBeginningIn != null && this.showDateTimeEndingIn != null)) {
                    
                try {
                    
                    queryString += 'SELECT Name, Poster__c, Description__c,';
                    queryString += ' (SELECT StartTime__c, Theater__r.Cinema__r.Name,';
                    queryString += ' Theater__r.Name FROM Showtimes__r';
                    
                    if ((this.showDateTimeBeginningIn != null && this.showDateTimeEndingIn != null)
                       || this.cinema != 'Choose cinema') {
                        
                        queryString += ' WHERE';
                           
                    	if (this.showDateTimeBeginningIn != null && this.showDateTimeEndingIn != null) {
                        
                        	queryString += ' StartTime__c >= ' + this.showDateTimeBeginningIn.format('YYYY-MM-DD') +
                                'T' + this.showDateTimeBeginningIn.format('hh:mm:ss') + 'Z';
                        	queryString += ' AND StartTime__c <= ' + this.showDateTimeEndingIn.format('YYYY-MM-DD') +
                                'T' + this.showDateTimeEndingIn.format('hh:mm:ss') + 'Z';
                    	}
                           
                    	if (this.cinema != 'Choose cinema') {
                    	
                            if (this.showDateTimeBeginningIn != null && this.showDateTimeEndingIn != null) {
                                
                                queryString += ' AND Theater__r.Cinema__r.Name = \'' + this.cinema + '\'';
                            } else {
                                
                                queryString += ' Theater__r.Cinema__r.Name = \'' + this.cinema + '\'';
                            }
                        }
                    }
                    
                    queryString += ' ORDER BY StartTime__c ASC)';
                    queryString += ' FROM Movie__c WHERE';
                    
                    if (this.movieTitle != null && !(this.movieTitle.isWhitespace())) {
                    	
                        Movie__c prepareMovieTitle = new Movie__c(Name = this.movieTitle + '%');
                        
                        queryString += ' Name LIKE \'' + this.movieTitle + '%\' AND';
                    }
                    
                    queryString += ' OwnerId = \'' + UserInfo.getUserId() + '\' ORDER BY Name ASC';
                    
                    eachMovie = Database.query(queryString);
                    
                    for (Movie__c movieSearch: eachMovie) {
                    
                        numberOfResults++;
                        
                        showTimes = '';
                        
                        movies += '<div style="color: #ffffb3"><br /><label><b>' + movieSearch.Name + '</b></label>' +
                            '<br /></div>';

						if (movieSearch.Poster__c != null) {
								
							movies += '<div style="color: white"><br /><label>' + movieSearch.Poster__c + '</label></div>';
                        }
                                                    
                        if (movieSearch.Description__c != null) {
                            
                            movies += '<div style="color: white"><label><b>Summary:</b></label><br /><br /><label>' +
                                movieSearch.Description__c + '</label><br /><br /></div>';
                        }
                                                    
                        for (Showtime__c showtimeSearch: movieSearch.Showtimes__r) {
                    		
                            if (showtimeSearch.StartTime__c != null && showtimeSearch.Theater__r.Cinema__r.Name != '') {
                            	
                                showTimes += '<div style="color: white"><label>Show time: ' +
                                    String.valueOf(showtimeSearch.StartTime__c.format('MM/dd/yyyy hh:mm a')) +
                                    ' EST</label><br /></div>';
                               	showTimes += '<div style="color: white"><label>Location: ' +
                                    showtimeSearch.Theater__r.Cinema__r.Name + '</label><br /><br /></div>';
                            }
                        }
                                                    
                       	if (showTimes == '') {
                            
                            movies += '<div style="color: white"><label>Sorry, no results are available for ' +
                                'showtimes and locations.</label></div>';
                        } else {
                            
                           	movies += showTimes;
                        }
                    }
                } catch (DMLException e) {
                    
                    System.debug('An expected database error has occurred: ' + e.getMessage());
                }
                
                if (numberOfResults > 0) {
                    
                    output += '<script type=\'text/javascript\'>\n';
                    output += 'function backToSearchMenu() {\n\n';
                    output += 'window.location = document.location.href.replace(\'#\', \'\');\n';
                    output += '}\n';
                    output += '</script>\n';
                    output += '<style type=\'text/css\'>\n';
                    output += '#formSection { display: none; }\n';
                    output += '</style>\n';
                    output += '<input type=\'button\' class=\'goBackToSearchMenu\' onclick=\'backToSearchMenu()\'' +
                                ' value=\'New search\' /><br />\n';
                    
                    output += movies;
                    
                    output += '<br /><input type=\'button\' class=\'goBackToSearchMenu\' onclick=\'backToSearchMenu()\'' +
                                ' value=\'New search\' />\n';
                } else {
                    
					output = '<div style="color: #ff8080"><label>Sorry, but your search returned no results for "' +
                        this.movieTitle + '".  Try a different spelling for your movie title, and/or broaden your ' +
                        'search criteria.</label></div>';                    
                }
            }
        }
        
        return output;
    }
}
