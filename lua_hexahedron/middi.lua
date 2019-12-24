local string = string
local table = table
local util = util
local concommand = concommand
local gui = gui


if SERVER then
	hook.Add( "PlayerSay", "MidiChatCommands", function( ply, chat )
		if string.StartWith( chat, '/' ) or string.StartWith( chat, '!' ) then
			local command = (string.StartWith( chat, '/' ) and string.match( chat, "/(.*)" )) or (string.StartWith( chat, '!' ) and string.match( chat, "!(.*)" )) local beep = "money"
			
			if command == "midi gui" then
				ply:ConCommand( "OpenMidiGui" )
				return ""
			elseif command == "midi debug 1" then
				ply:ConCommand( "MidiDebugon" )
				return ""
			elseif command == "midi debug 0" then
				ply:ConCommand( "MidiDebugoff" )
				return ""
			else
			end
			
		end
	end )
end

if CLIENT then

	

		print("===========MIDI===========")
		print("MIDI-Init: TRYING TO INITALIZE MODULE...")
	if file.Exists("lua/bin/gmcl_midi_win32.dll", "MOD") or file.Exists("lua/bin/gmcl_midi_linux.dll", "MOD") then 
		print("MIDI-Init: GMCL-MODULE DETECTED!")
		require("midi")
		print("MIDI-Init: SUCCESSFULLY INITALIZED")
	
		
		concommand.Add("OpenMidiGui", function(ply, cmd, args)
		if table.Count(midi.GetPorts()) > 0 then
						Derma_Query("Which device you would like to use?" ..(table.Count(midi.GetPorts()) > 3 and " (Max. 3 devices)" or ""), --Interface
							"MIDI: Device selection",
							"Cancel",
							function() if midi.IsOpened() then midi.Close() end end,
							midi.GetPorts()[0] or nil,
							function() if midi.GetPorts()[0] then midi.Open(0) end end,
							midi.GetPorts()[1] or nil,
							function() if midi.GetPorts()[1] then midi.Open(1) end end,
							midi.GetPorts()[2] or nil,
							function() if midi.GetPorts()[2] then midi.Open(2) end end
							)
					else
						
						chat.AddText(Color(0,255,0), "MIDI:", Color(255,0,0), " Can't find a MIDI device!")
					end	
		end)
		
		concommand.Add("MidiDebugon", function(ply, cmd, args)
		hook.Add( 'PlayerSay', 'Mididebug', function( ply, text, teamChat, isDead )
		  if ( text == '!midi debug 1' ) then
		  hook.Add("MIDI", "print midi events", function(time, code, par1, par2, ...)
			print("MIDI-Test:")
			-- The code is a byte (number between 0 and 254).
			print("MIDI EVENT", code, par1, par2, ...)
			print("Event Code:", midi.GetCommandCode(code))
			print("Event Channel:", midi.GetCommandChannel(code))
			print("Event Name:", midi.GetCommandName(code))

			-- The parameters of the code
			print("Parameter", par1, par2, ...)
		end)
					chat.AddText(Color(0,255,0), "MIDI:", Color(100,200,200), " Debugmode activated")
				return true
		  end
	end )
		end)
		
		concommand.Add("MidiDebugoff", function(ply, cmd, args)
		hook.Add( 'PlayerSay', 'Mididebugdis', function( ply, text, teamChat, isDead )
		  if ( text == '!midi debug 0' ) then
		  hook.Remove("MIDI", "print midi events")
					chat.AddText(Color(0,255,0), "MIDI:", Color(100,200,200), " Debugmode deactivated")
				return true
		  end
	end )
		end)
		
		
		
		print("MIDI-Init: TRYING TO FIND DEVICES")
		if table.Count(midi.GetPorts()) > 0 then -- use table.Count here, the first index is 0
		print("MIDI-Init: DEVICES FOUND")
			
					chat.AddText(Color(0,255,0), "MIDI:", Color(255,255,255), " Successfully initialized and device(s) found!")
				else 
					
						chat.AddText(Color(0,255,0), "MIDI:", Color(255,0,0), " MODULE CAN'T BE INITALIZED.")
						chat.AddText(Color(0,255,0), "MIDI:", Color(255,0,0), " CAN'T FIND A COMPATIBLE DEVICE.")
						print("===========MIDI===========")
				return
						
			end
			
			print("Port open:", midi.IsOpened())
			print("MIDI INITALIZED")
			print("===========MIDI===========")

			local MIDIKeys = {
				[36] = { Sound = "a1"  }, -- C
				[37] = { Sound = "b1"  },
				[38] = { Sound = "a2"  },
				[39] = { Sound = "b2"  },
				[40] = { Sound = "a3"  },
				[41] = { Sound = "a4"  },
				[42] = { Sound = "b3"  },
				[43] = { Sound = "a5"  },
				[44] = { Sound = "b4"  },
				[45] = { Sound = "a6"  },
				[46] = { Sound = "b5"  },
				[47] = { Sound = "a7"  },
				[48] = { Sound = "a8"  }, -- c
				[49] = { Sound = "b6"  },
				[50] = { Sound = "a9"  },
				[51] = { Sound = "b7"  },
				[52] = { Sound = "a10" },
				[53] = { Sound = "a11" },
				[54] = { Sound = "b8"  },
				[55] = { Sound = "a12" },
				[56] = { Sound = "b9"  },
				[57] = { Sound = "a13" },
				[58] = { Sound = "b10" },
				[59] = { Sound = "a14" },
				[60] = { Sound = "a15" }, -- c'
				[61] = { Sound = "b11" },
				[62] = { Sound = "a16" },
				[63] = { Sound = "b12" },
				[64] = { Sound = "a17" },
				[65] = { Sound = "a18" },
				[66] = { Sound = "b13" },
				[67] = { Sound = "a19" },
				[68] = { Sound = "b14" },
				[69] = { Sound = "a20" },
				[70] = { Sound = "b15" },
				[71] = { Sound = "a21" },
				[72] = { Sound = "a22" }, -- c''
				[73] = { Sound = "b16" },
				[74] = { Sound = "a23" },
				[75] = { Sound = "b17" },
				[76] = { Sound = "a24" },
				[77] = { Sound = "a25" },
				[78] = { Sound = "b18" },
				[79] = { Sound = "a26" },
				[80] = { Sound = "b19" },
				[81] = { Sound = "a27" },
				[82] = { Sound = "b20" },
				[83] = { Sound = "a28" },
				[84] = { Sound = "a29" }, -- c'''
				[85] = { Sound = "b21" },
				[86] = { Sound = "a30" },
				[87] = { Sound = "b22" },
				[88] = { Sound = "a31" },
				[89] = { Sound = "a32" },
				[90] = { Sound = "b23" },
				[91] = { Sound = "a33" },
				[92] = { Sound = "b24" },
				[93] = { Sound = "a34" },
				[94] = { Sound = "b25" },
				[95] = { Sound = "a35" },
				[96] = { Sound = "a36" }, -- c''''
			}

			hook.Add("MIDI", "playablePiano", function(time, command, note, velocity)
				local instrument = LocalPlayer().Instrument
				if !IsValid( instrument ) then return end

				-- Zero velocity NOTE_ON substitutes NOTE_OFF
				if !midi || midi.GetCommandName( command ) != "NOTE_ON" || velocity == 0 || !MIDIKeys || !MIDIKeys[note] then return end

				 instrument:OnRegisteredKeyPlayed(MIDIKeys[note].Sound)

				net.Start("InstrumentNetwork")
					net.WriteEntity(instrument)
					net.WriteInt(INSTNET_PLAY, 3)
					net.WriteString(MIDIKeys[note].Sound)
				net.SendToServer()
			end)
		
	else
		print("MIDI-Init: INITIALIZATION FAILED...")
		print("MIDI-Init: CAN'T FIND THE GMCL-MODULE!")
		print("===========MIDI===========")
	end
end