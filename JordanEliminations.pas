uses System;
uses MatrixLib;
const
  matrixRowsAmount: integer = 3;
  matrixColumnsAmount: integer = 4;

var
  pivotRowIndex: integer;
  pivotColumnIndex: integer;
  matrix: array[,] of real;
  resultMatrix: array[,] of real;
  extendedResultMatrix: MatrixLib.Matrix;
  tempMatrix: array[,] of real;
  originFuncCoefficients: array of real;
  matrixTransformationCount: integer := 1;
  matrixExample1 := new real[5, 6] (
    (3.0, 1.0,  -4.0,  2.0,  -5.0, 9.0),
    (6.0, 0.0,  1.0,  -3.0,  4.0, -5.0),
    (1.0, 0.0, 1.0, -1.0, 1.0, -1.0),
    (0.0, 2.0, 6.0, -5.0, 1.0, 4.0),
    (-10.0, -1.0, 2.0, 2.0, 0.0, -3.0)
  );
  
  extendedMatrixExample1: MatrixLib.Matrix := (
    baseMatrix: matrixExample1;
    rowStringX: new string[5] ('-x1', '-x2', '-x3', '-x4', '-x5');
    columnStringX: new string[5] ('x6=', 'x7=', 'x8=', 'f=', 'g=');
  );

begin
  extendedResultMatrix := extendedMatrixExample1;
  originFuncCoefficients := extendedResultMatrix.baseMatrix
    .Row(extendedResultMatrix.baseMatrix.GetLength(0) - 2).Skip(1).ToArray();
  
  Writeln('Исходная матрица');
  extendedResultMatrix.Print();
  
  // part 1
  while (true) do
  begin
    pivotColumnIndex := extendedResultMatrix.FindPivotColumnIndex();    
    pivotRowIndex := extendedResultMatrix.FindPivotRowIndex(pivotColumnIndex);
    
    // поиск отрицательного элемента в столбце. begin
    var isAllColumnElementsNegative := true;
    for var i := 0 to extendedResultMatrix.baseMatrix.GetLength(0) - 2 do
    begin
      if (extendedResultMatrix.baseMatrix[i, pivotColumnIndex] > 0) then
      begin
        isAllColumnElementsNegative := false;
        break;
      end;
    end;
    
    if (isAllColumnElementsNegative) then
    begin
      Writeln('Нет решений');
      exit;
    end;
    // поиск отрицательного элемента в столбце. end
    
    Writeln('Разрешающий элемент: ', extendedResultMatrix.baseMatrix[pivotRowIndex, pivotColumnIndex]:0:2);
    Writeln('Индекс (k, s): [', pivotRowIndex + 1, ', ' ,pivotColumnIndex, ']');
    tempMatrix := JordanElimination(extendedResultMatrix.baseMatrix, (pivotRowIndex, pivotColumnIndex));
    
    extendedResultMatrix.baseMatrix := tempMatrix;
    extendedResultMatrix.SwapRowAndColumnVariables(pivotRowIndex, pivotColumnIndex - 1);
    Writeln('Преобразование ', matrixTransformationCount);
    extendedResultMatrix.Print();
    
    if (extendedResultMatrix.IsAllRowElementsNotNegative(
        extendedResultMatrix.baseMatrix.GetLength(0) - 1))
    then
      break;
    
    matrixTransformationCount += 1;
    Writeln('------------------------------------------------------------------');
  end;
  
  // part 2
  while (true) do
  begin
    // поиск индекса столбца, в котором элемент из строки g равен 0, а из строки f меньше 0. begin
    pivotColumnIndex := -1;
    for var i := 1 to extendedResultMatrix.baseMatrix.GetLength(1) - 1 do
      if ((extendedResultMatrix.baseMatrix[extendedResultMatrix.baseMatrix.GetLength(0) - 1, i] = 0)
          and (extendedResultMatrix.baseMatrix[extendedResultMatrix.baseMatrix.GetLength(0) - 2, i] < 0)) then
      begin
        pivotColumnIndex := i;
        break;
      end;
    // поиск индекса столбца, в котором элемент из строки g равен 0, а из строки f меньше 0. end
    
    if (pivotColumnIndex > 0) then
    begin
      // поиск отрицательного элемента в столбце. begin
      var isAllColumnElementsNegative := true;
      for var i := 0 to extendedResultMatrix.baseMatrix.GetLength(0) - 2 do
      begin
        if (extendedResultMatrix.baseMatrix[i, pivotColumnIndex] > 0) then
        begin
          isAllColumnElementsNegative := false;
          break;
        end;
      end;
      
      if (isAllColumnElementsNegative) then
      begin
        Writeln('Нет решений');
        exit;
      end;
      // поиск отрицательного элемента в столбце. end
      
      pivotRowIndex := extendedResultMatrix.FindPivotRowIndex(pivotColumnIndex);
      Writeln('Индекс (k, s): [', pivotRowIndex + 1, ', ' ,pivotColumnIndex, ']');
      
      tempMatrix := JordanElimination(extendedResultMatrix.baseMatrix, (pivotRowIndex, pivotColumnIndex));
      extendedResultMatrix.baseMatrix := tempMatrix;
      extendedResultMatrix.SwapRowAndColumnVariables(pivotRowIndex, pivotColumnIndex - 1);
      Writeln('Преобразование ', matrixTransformationCount);
      extendedResultMatrix.Print();
      
      matrixTransformationCount += 1;
      Writeln('------------------------------------------------------------------');
    end
    else
    begin
      Writeln('Решение:');
      
      // исключаем строки g, f и столбец уравнения, поэтому длина - 3
      var xValues := ArrFill(
        extendedResultMatrix.baseMatrix.GetLength(0) + extendedResultMatrix.baseMatrix.GetLength(1) - 3,
        0.0
      );
      
      // обход столбца
      for var i := 0 to extendedResultMatrix.columnStringX.Length - 3 do
      begin
        var variableName := extendedResultMatrix.columnStringX[i];
        var index := StrToInt(variableName.Substring(1, variableName.Length - 2)) - 1;
        var columnXIndex := extendedResultMatrix.columnStringX.IndexOf(variableName);
        xValues[index] := extendedResultMatrix.baseMatrix[i, 0];
      end;
      
      // вывод ответа
      Write('x = ');
      for var i := 0 to xValues.Length - 1 do
      begin
        Write(xValues[i], '  ');
      end;
      Writeln();
      
      var answer := 0.0;
      for var i := 0 to extendedResultMatrix.baseMatrix.ColCount() - 2 do
        answer += -originFuncCoefficients[i] * xValues[i];
      
      Writeln('F(x) = ', answer:0:3);
      
      exit;
    end;
  end;
end.
