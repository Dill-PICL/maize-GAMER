get_ont <- function(go_list){
    counter <- 0
    total_gos <- length(go_list)
    print(paste("Total",total_gos,"to process"))
    test_ont <- lapply(go_list,function(x){
        #print(x)
        counter <<- counter+1
        #print(counter)
        if(counter %% 100 == 0){
            print(paste("Processing GO id #",counter,"of",total_gos))
        }
        if(!is.null(GOTERM[[x]])){
            Ontology(GOTERM[[x]])    
        }else{
            "NA"
        }
    })
    return(unlist(test_ont))
}
