function doGet(e) {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  var rows = sheet.getDataRange().getValues();
  var result = [];
  
  for (var i = 1; i < rows.length; i++) {
    var row = rows[i];
    if (row[0]) { // Solo lee las filas que tengan un ID válido (ignora los huecos vacíos)
      result.push({
        id: String(row[0]),
        nombre: row[1],
        categoria: row[2],
        precio: row[3],
        cantidad: row[4],
        comprado: row[5],
        codigoBarras: row[6]
      });
    }
  }
  return ContentService.createTextOutput(JSON.stringify(result)).setMimeType(ContentService.MimeType.JSON);
}

function doPost(e) {
  try {
    var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
    var data = JSON.parse(e.postData.contents);

    var action = data.action; // 'ADD', 'UPDATE' o 'DELETE'
    var id = String(data.id);

    // 1. SI LA ACCIÓN ES AGREGAR (ADD)
    if (action === 'ADD') {
      var values = sheet.getDataRange().getValues();
      var targetRow = values.length + 1; // Por defecto, al final si está todo lleno

      // Buscamos el primer hueco vacío real mirando la columna A (ID)
      for (var i = 1; i < values.length; i++) {
        if (!values[i][0]) { // Si la celda del ID está vacía
          targetRow = i + 1;
          break;
        }
      }

      // Escribimos en esa fila exacta asegurando el lugar
      sheet.getRange(targetRow, 1, 1, 7).setValues([[
        id, 
        data.nombre, 
        data.categoria, 
        data.precio, 
        data.cantidad, 
        data.comprado, 
        data.codigoBarras || ""
      ]]);
      
      return ContentService.createTextOutput(JSON.stringify({"status": "success"})).setMimeType(ContentService.MimeType.JSON);
    }

    // 2. BUSCAR LA FILA EXACTA PARA UPDATE O DELETE
    var dataRange = sheet.getDataRange();
    var values = dataRange.getValues();
    var rowIndex = -1;

    for (var i = 1; i < values.length; i++) {
      if (String(values[i][0]) === id) { 
        rowIndex = i + 1; 
        break;
      }
    }

    // 3. EJECUTAR UPDATE O DELETE
    if (rowIndex !== -1) {
      if (action === 'UPDATE') {
        sheet.getRange(rowIndex, 2).setValue(data.nombre);
        sheet.getRange(rowIndex, 3).setValue(data.categoria);
        sheet.getRange(rowIndex, 4).setValue(data.precio);
        sheet.getRange(rowIndex, 5).setValue(data.cantidad);
        sheet.getRange(rowIndex, 6).setValue(data.comprado);
        if (data.codigoBarras) {
          sheet.getRange(rowIndex, 7).setValue(data.codigoBarras);
        }
      } else if (action === 'DELETE') {
        // En vez de borrar la fila (que rompe el orden), limpiamos el contenido
        // de esa fila para que quede libre para el próximo producto
        sheet.getRange(rowIndex, 1, 1, 7).clearContent();
      }
    }

    return ContentService.createTextOutput(JSON.stringify({"status": "success"})).setMimeType(ContentService.MimeType.JSON);

  } catch (error) {
    return ContentService.createTextOutput(JSON.stringify({"error": error.toString()})).setMimeType(ContentService.MimeType.JSON);
  }
}

function doGet(e) {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  var rows = sheet.getDataRange().getValues();
  var result = [];
  
  for (var i = 1; i < rows.length; i++) {
    var row = rows[i];
    if (row[0]) { // Solo lee las filas que tengan un ID válido (ignora los huecos vacíos)
      result.push({
        id: String(row[0]),
        nombre: row[1],
        categoria: row[2],
        precio: row[3],
        cantidad: row[4],
        comprado: row[5],
        codigoBarras: row[6]
      });
    }
  }
  return ContentService.createTextOutput(JSON.stringify(result)).setMimeType(ContentService.MimeType.JSON);
}