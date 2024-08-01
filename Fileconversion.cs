using Microsoft.Office.Interop.Word;
using System;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;

namespace ImmutableFileConversionService
{
    public class FileConversion
    {
        readonly string connectionString;
        readonly DatabaseManager databaseManager;

        public FileConversion(string _connectionString)
        {
            this.connectionString = _connectionString;
            databaseManager = new DatabaseManager(connectionString);
        }

        public void RTFTODOCXConversion(string rtfFilePath, string documentPath, MessageBody messageBody, string sensitivityPath)
        {
            Application wordApp = null;
            Document doc = null;
            Document newdoc = null;

            try
            {
                wordApp = new Application();
                doc = wordApp.Documents.Open(rtfFilePath, Visible: false, ReadOnly: true);                
                WdOrientation orientation = doc.PageSetup.Orientation;
                newdoc = wordApp.Documents.Add(Path.Combine(sensitivityPath, orientation == WdOrientation.wdOrientPortrait ? "portrait.docx" : "landscape.docx"));
                doc.Content.Copy();
                newdoc.Content.Paste();

                foreach (Table table in newdoc.Tables)
                {
                    ContentControl objParentContentControl = GetParentContentControl(table.Range);

                    if (objParentContentControl == null)
                    {
                        ContentControl objContentControl = newdoc.ContentControls.Add(WdContentControlType.wdContentControlRichText, table.Range);
                        objContentControl.LockContentControl = true;
                        objContentControl.LockContents = true;
                    }
                    else
                    {
                        objParentContentControl.LockContentControl = true;
                        objParentContentControl.LockContents = true;
                    }
                }

                newdoc.SaveAs2(documentPath, WdSaveFormat.wdFormatDocumentDefault);
                databaseManager.InsertData(Convert.ToInt32(messageBody.fileid), $"DOCX converted file : {Path.GetFileName(documentPath)}", "Information");
            }
            catch (Exception ex)
            {
                HandleConversionException(ex, messageBody);
            }
            finally
            {
                ReleaseComObjects(doc, newdoc, wordApp);
            }
        }

        public void RTFTOPDFConversion(string rtfFilePath, string pdfFilePath, MessageBody messageBody)
        {
            Application wordApp = null;
            Document doc = null;
            Document newdoc = null;

            try
            {
                wordApp = new Application();
                doc = wordApp.Documents.Open(rtfFilePath, Visible: false);

                doc.Content.Copy();
                newdoc = wordApp.Documents.Add();
                wordApp.Selection.Paste();

                newdoc.SaveAs2(pdfFilePath, WdSaveFormat.wdFormatPDF);
                databaseManager.InsertData(Convert.ToInt32(messageBody.fileid), $"PDF converted file : {Path.GetFileName(pdfFilePath)}", "Information");
            }
            catch (Exception ex)
            {
                HandleConversionException(ex, messageBody);
            }
            finally
            {
                ReleaseComObjects(doc, newdoc, wordApp);
            }
        }

        private ContentControl GetParentContentControl(Microsoft.Office.Interop.Word.Range range)
        {
            ContentControl objParentContentControl = null;
            if (range.ContentControls.Count == 0)
                objParentContentControl = range.ParentContentControl;

            if (objParentContentControl == null)
                objParentContentControl = range.ContentControls.OfType<ContentControl>().FirstOrDefault();

            return objParentContentControl;
        }

        private void HandleConversionException(Exception ex, MessageBody messageBody)
        {
            databaseManager.InsertData(Convert.ToInt32(messageBody.fileid), $"{ex.TargetSite.Name} : {ex.Message}", "Error");
            databaseManager.UpdateDataConversionFailed(Convert.ToInt32(messageBody.fileid));
        }

        private void ReleaseComObjects(Document doc, Document newdoc, Application wordApp)
        {
            if (doc != null)
            {
                doc.Close(false);
                Marshal.ReleaseComObject(doc);
            }

            if (newdoc != null)
            {
                newdoc.Close(false);
                Marshal.ReleaseComObject(newdoc);
            }

            if (wordApp != null)
            {
                wordApp.Quit();
                Marshal.ReleaseComObject(wordApp);
            }
        }

        public string TargetConversion(string sourceFilePath, MessageBody messageBody, string downloadLocation, string sensitivityPath)
        {
            string outputFilePath;
            try
            {
                if (messageBody.targetconversion == "docx")
                {
                    outputFilePath = Path.Combine(downloadLocation, messageBody.filename.Replace(".rtf", ".docx"));
                    RTFTODOCXConversion(sourceFilePath, outputFilePath, messageBody, sensitivityPath);
                }
                else
                {
                    outputFilePath = Path.Combine(downloadLocation, messageBody.filename.Replace(".rtf", ".pdf"));
                    RTFTOPDFConversion(sourceFilePath, outputFilePath, messageBody);
                }
                databaseManager.UpdateDataConversionEnd(Convert.ToInt32(messageBody.fileid));
                databaseManager.InsertData(Convert.ToInt32(messageBody.fileid), $"Conversion completed for file : {messageBody.filename}", "Information");
                return outputFilePath;
            }
            catch (Exception ex)
            {
                HandleConversionException(ex, messageBody);
                if (File.Exists(sourceFilePath))
                {
                    File.Delete(sourceFilePath);
                }
                return ex.Message;
            }
        }

        public void DeleteFile(string sourceFilePath, MessageBody messageBody, string outputFilePath)
        {
            try
            {
                if (File.Exists(sourceFilePath))
                {
                    File.Delete(sourceFilePath);
                }
                if (File.Exists(outputFilePath))
                {
                    File.Delete(outputFilePath);
                }
            }
            catch (Exception ex)
            {
                HandleConversionException(ex, messageBody);
            }
        }
    }
}
