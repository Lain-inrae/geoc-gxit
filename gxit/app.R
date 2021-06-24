library(shiny)

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
      tags$h5("Input format settings"),

      checkboxInput("header", "Input has a header?", TRUE),

      radioButtons(
        "sep", "Which separator caracters is used?",
        choices=c(
          Comma=",",
          Semicolon=";",
          Tab="\t"
        ),
        selected=","
      ),

      radioButtons(
        "quote", "Which quoting character is used?",
        choices=c(
          None="",
          "Double Quote"='"',
          "Single Quote"="'"
        ),
        selected='"'
      ),

      radioButtons(
        "disp", "Display only first lines?",
        choices=c(
          Yes="head",
          No="all"
        ),
        selected="head"
      ),

      tags$hr(),
      tags$h5("Output format settings"),

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

    tableOutput("contents")
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
        header=input$header,
        sep=input$sep,
        quote=input$quote
      )
      curent_dataframe <<- read.csv(
        input$uploaded_file$datapath,
        header=TRUE,
        sep=input$sep,
        quote=input$quote
      )
    },
      error=function(e) {
        # return a safeError if a parsing error occurs
        stop(safeError(e))
    })

    if(input$disp == "head") {
      return(head(df))
    } else {
      return(df)
    }

  })

}

server_download_handler <- function(input) {
  downloadHandler(
    filename=function() {
      "curent_dataset.csv"
    },
    content=function(file) {
      write.table(curent_dataframe, file, row.names=FALSE,
        sep=input$out_sep,
        quote=input$out_quote == "TRUE"
      )
    }
  )
}

server <- function(input, output) {

  ## upload section
  output$contents <- server_upload_handler(input)

  # Downloadable csv of selected dataset
  output$downloadData <- server_download_handler(input)

}

shinyApp(ui, server)
