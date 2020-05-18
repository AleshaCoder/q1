{$reference System.Speech.dll}
unit module;

interface
procedure SaveMP3(name,text: string; speed,voice:integer);

procedure Speak(s: string);

procedure Speed(i:integer);

procedure Voice(i: integer);

procedure SpeakAsync(s: string);

implementation

uses System.Speech.Synthesis;

var ss: SpeechSynthesizer;

procedure SaveMP3(name,text: string; speed,voice:integer);
begin
  var q1:=new SpeechSynthesizer;
  q1.SetOutputToWaveFile(name); 
  q1.Rate:=speed;
  var voices := q1.GetInstalledVoices;
  q1.SelectVoice(voices[voice].VoiceInfo.Name);
  q1.Speak(text);
  q1.SetOutputToNull;
end;
procedure Speed(i: integer);
begin
  ss.Rate:=i;
end;

procedure Voice(i: integer);
begin
  var voices := ss.GetInstalledVoices;
  ss.SelectVoiceByHints(VoiceGender.Male, VoiceAge.Teen, 1, System.Globalization.CultureInfo.CreateSpecificCulture('ru-RU'));
  ss.SelectVoice(voices[i].VoiceInfo.Name);
end;

procedure Speak(s: string);
begin
  ss.Speak(s);
end;

procedure SpeakAsync(s: string);
begin
  ss.SpeakAsync(s);
end;

begin
  ss := new SpeechSynthesizer;
  var voices := ss.GetInstalledVoices;
  ss.SelectVoice(voices[0].VoiceInfo.Name)
end.