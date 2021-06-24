library(shiny)

## The dataframe of the curent file.
curent_dataframe <- NULL


ui <- fluidPage(

  titlePanel("Uploading Files"),

  sidebarLayout(

    sidebarPanel(

      fileInput(
        "uploaded_file", "Choose CSV File",
        multiple=FALSE,
        accept=c(
          "text/csv",
          "text/comma-separated-values,text/plain",
          ".csv"
        )
      ),

      tags$hr(),
      tags$h3("Input format settings"),

      checkboxInput("has_a_header", "Input has a header?", TRUE),

      radioButtons(
        "input_sep", "Which separator caracters is used?",
        choices=c(
          Comma=",",
          Semicolon=";",
          Tab="\t"
        ),
        selected=","
      ),

      radioButtons(
        "input_quote", "Which quoting character is used?",
        choices=c(
          None="",
          "Double Quote"='"',
          "Single Quote"="'"
        ),
        selected='"'
      ),

      radioButtons(
        "dispplay_first_lines_only", "Display only first lines?",
        choices=c(
          Yes="head",
          No="all"
        ),
        selected="head"
      ),

      tags$hr(),
      tags$h3("Output format settings"),

      radioButtons(
        "out_sep", "Separator",
        choices=c(
          Comma=",",
          Semicolon=";",
          Tab="\t"
        ),
        selected=","
      ),
      radioButtons(
        "out_quote", "Quoting?",
        choices=c(
          Yes="TRUE",
          No="FALSE"
        ),
        selected=FALSE
      ),
      downloadButton("downloadData", "Download")
    ),

    tableOutput("parsed_csv_content")

  )
)

server_upload_handler <- function(input) {
  renderTable({

    # input$uploaded_file will be NULL initially. After the user selects
    # and uploads a file, head of that data file by default,
    # or all rows if selected, will be shown.

    req(input$uploaded_file)

    # when reading semicolon separated files,
    # having a comma separator causes `read.csv` to error
    tryCatch({
      df <- read.csv(
        input$uploaded_file$datapath,
        header=input$has_a_header,
        sep=input$input_sep,
        quote=input$input_quote
      )
      ## We don't want a fake header for the output file.
      ## So, we consider the inpout file has a header.
      curent_dataframe <<- read.csv(
        input$uploaded_file$datapath,
        header=TRUE,
        sep=input$input_sep,
        quote=input$input_quote
      )
    },
      error=function(e) {
        # return a safeError if a parsing error occurs
        stop(safeError(e))
    })

    if(input$dispplay_first_lines_only == "head") {
      return(head(df))
    } else {
      return(df)
    }

  })

}

server_download_handler <- function(input) {
  downloadHandler(
    filename="curent_dataset.csv",
    content=function(output_file) {
      ## We write the content of the original file,
      ## But with the sep and quotes defined in the form
      write.table(
        curent_dataframe,
        output_file,
        row.names=FALSE,
        sep=input$out_sep,
        quote=input$out_quote == "TRUE"
      )
    }
  )
}

server <- function(input, output) {

  ## upload section
  output$parsed_csv_content <- server_upload_handler(input)

  # Downloadable csv section
  output$downloadData <- server_download_handler(input)

}

shinyApp(ui, server)
