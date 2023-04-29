/* @desc code moved as a part of OLC */

public with sharing class ReportFinderUtil {

  public ReportFinderUtil(){}
  
  public String findReportId(String reportName){
    
    SObject myReport = [select Id,Name From Report Where Name=:reportName];
    return myReport.Id;
    
  }
  
}