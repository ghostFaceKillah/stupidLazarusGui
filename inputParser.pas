unit inputParser;

interface

type

  Answer = record 
    number : Integer;
    content : String;
  end;

  PAnswer = ^Answer;

  Status = (notAnswered, notChecked, correct, incorrect);

  PGap = ^Gap;

  Gap = record
    number : Integer;
    state : Status;
  end;

  PartType = (a, g);

  PPart = ^Part;

  Part = record
    is : String;
    g : PGap;
    sentence : String;
    next : PPart;
  end;

  PQuestion = ^Question;

  Question = record
    parts : PPart;
    answers : Array [1..6] of PAnswer;
    next : PQuestion;
  end;

procedure parseQuizFromFile(var Quiz : PQuestion);

procedure mainTest();

var
  quiz : PQuestion;

implementation

function charToInt(const c : Char) : Integer;
begin
  charToInt := ord(c) - ord('0');
end;

function whereInString(const c : char; const s : String) : Integer;
  var
     isThere : Boolean;
     i : Integer;
  begin
    isThere := false;
    i := 1;
    while (not(isThere)) and (i <= length(s)) do begin
      isThere := (s[i] = c);
      inc(i);
    end;
    if isThere then
      whereInString := i - 1
    else
      whereInString := -1;
  end;

procedure debugPrintQuiz(Quiz : PQuestion);
  var
    txt : PPart;
    i : Integer;
  begin
    while (Quiz <> nil) do begin
      txt := Quiz^.parts;
      while (txt <> nil) do begin
        if (txt^.is = 'gap') then
          write('_______ ')
        else
          write(txt^.sentence);
        txt := txt^.next;
      end;
      writeln();
      i := 1;
      while (Quiz^.answers[i] <> nil) and (i <= 6) do begin
        writeln(Quiz^.answers[i]^.content, '    it goes to gap no. ',
          Quiz^.answers[i]^.number);
        inc(i);
      end;
    Quiz := Quiz^.next;
    writeln();
    end;
  end;


procedure parseQuizFromFile(var Quiz : PQuestion);
  var
    userFile : Text;
    nextQuestion : Question;
    currentQuizPosition : PQuestion;

  procedure initQuiz();
  begin
    new(quiz);
    currentQuizPosition := quiz;
  end;

  procedure addToQuiz(this : PQuestion);
    begin
      currentQuizPosition^.next := this;
      currentQuizPosition := currentQuizPosition^.next;
    end;

  function parseNextQuestion() : PQuestion;
    var 
      this : PQuestion;
      i, uPos, gapNo : integer;
      current : String;
      worker : PPart;
    begin
      new(this);
      this^.parts := new(PPart);
      worker := this^.parts;
      for i := 1 to 6 do
        this^.answers[i] := nil;
      this^.next := nil;
      readln(userFile, current);
      // DBG  writeln(current);
      i := 1;
      gapNo := 1;
      while (current <> '') and not(eof(userFile)) do begin
        if copy(current, 1, 2) = '*(' then begin
          new(this^.answers[i]);
          this^.answers[i]^.number := charToInt(current[3]);
          this^.answers[i]^.content := copy(current, 6, length(current));
          inc(i);
        end else 
          while (current <> '') do begin
            uPos := whereInString('_', current);
            if (uPos = -1) or (copy(current, 1, uPos-1) <> '') then begin
              new(worker^.next);
              worker := worker^.next;
              worker^.is := 'text';
              worker^.g := nil;
              if (uPos = -1) then begin
                worker^.sentence := current;
                current := '';
              end else
                worker^.sentence := copy(current, 1, uPos-1);
            end;
            if (uPos <> -1) then begin
              new(worker^.next);
              worker := worker^.next;
              worker^.is := 'gap';
              new(worker^.g);
              worker^.g^.state := notAnswered;
              worker^.g^.number := gapNo;
              inc(gapNo);
              while (uPos <= length(current)) and (current[uPos] = '_') do
                inc(uPos);
              current := copy(current, uPos, length(current));
            end;
          end;
        readln(userFile, current);
        // DBG writeln(current);
      end;
      this^.parts := this^.parts^.next;
      // memleak
      parseNextQuestion := this;
    end;

  begin
    Assign(userFile, 'q1.txt');
    reset(userFile);
    initQuiz();
    while not(eof(userFile)) do begin
      addToQuiz(parseNextQuestion());
    end;
   debugPrintQuiz(Quiz);
  end;

procedure mainTest();
  var
    fakeQuiz : PQuestion;
  begin
    parseQuizFromFile(fakeQuiz);
  end;

end.
