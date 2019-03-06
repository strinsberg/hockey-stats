# stats.awk print the records of all players with >= stats for each provided
# category=value.
# Requires full.csv

  ### Global array information
  # stats -> array of stat info, wheather to show default conditions in addition
  #     to the ones specified, and what column to sort by if desired.
  # fan_points -> array assigning point values to stats
  #
  # conditions -> array of stat conditions to check records against
  # records -> all records that satisfy the stat conditions
  # multiples -> all players that satisfied the conditions in more than one year.
  #     indexed by player name for a string of all the years they did it.
  
  ### Global constats/others
  # LEN_COND -> length of the conditions array
  # LEN_RECS -> length of the records array
  #
  # status -> program status when exiting in error. if < 0 upon reaching end
  #     program will exit and return status without any more processing.


######## Begin ###############################################################

BEGIN {
  # set column_names -> array of column names indexed by column numbers
  column_names[1] = "player"
  column_names[2] = "age"
  column_names[3] = "pos"
  column_names[4] = "tm"
  column_names[5] = "gp"
  column_names[6] = "g"
  column_names[7] = "a"
  column_names[8] = "pts"
  column_names[9] = "p/gp"
  column_names[10] = "dif"
  column_names[11] = "pim"
  column_names[12] = "evg"
  column_names[13] = "ppg"
  column_names[14] = "shg"
  column_names[15] = "gwg"
  column_names[16] = "eva"
  column_names[17] = "ppa"
  column_names[18] = "sha"
  column_names[19] = "ppp"
  column_names[20] = "s"
  column_names[21] = "spr"
  column_names[22] = "toi"
  column_names[23] = "avt"
  column_names[24] = "blk"
  column_names[25] = "hit"
  column_names[26] = "fow"
  column_names[27] = "fol"
  column_names[28] = "fpr"
  column_names[29] = "year"
  
  # added columns
  column_names[30] = "fpt"
  column_names[31] = "f/g"
  
  LEN_COLS = 31 # length of the columns/column_names arrays
  
  # set columns -> array of column numbers indexed by column names
  for (i=1; i<LEN_COLS; ++i)
    columns[column_names[i]] = i
  
  # Load configuration data
  load_config()
  
  # Set field seperators -- FS and RS because config sets different ones
  FS = ","
  RS = "\n"
  OFS = ","
  
  # parse the command line arguments to set conditions to use in filtering
  # the records
  parse_args()
}



######## Main ################################################################

# If a record satisfies the stat conditions add it to the records array
( has_stats() ) {

  # Calculate additional column values
  # fan points total
  fan = calc_fpts()
  # fan points per game rounded to 2 decimal places
  fan_gp = int( (fan / $columns["gp"]) * 100 ) / 100
  
  # Add columns for fan points and fan points per game
  NF += 2
  $(NF - 1) = fan
  $NF = fan_gp
  
  records[++LEN_RECS] = $0

  # Add the year to a string of year the player satisfied the stat conditions
  player = $columns["player"]
  multiples[player] = multiples[player] $columns["year"] ", "
}



######## END #################################################################

END {
  # ignore this if program quit with error
  if ( status < 0 )
    exit status
  
  OFS = "\t" # change OFS for nicer printing
  
  # Output info
  print_conditions()
  print_headers()
  
  # sort the records
  if ( stats["sort"] ) {
    col_name = stats["sort"]
    if ( conditions["player"] && col_name == "player") {
      # don't sort
    } else {
      sort_records(records, LEN_RECS, columns[col_name])
    }
  }
  
  # Print report
  print_records()
  if ( !conditions["player"] )
    print_multiples()
}



######## Functions ###########################################################

### Loads the configuration file -> uses globals
function load_config(   _len, i, j) {
  # Set config file seporators
  FS = "\n"
  RS = ""
  
  # Read the config file
  while ((getline < "config") > 0) {
    # Set whether to show default columns and what column to sort by
    # Also if a column is listed as a default column sets stats["stat name"] = 1
    if ($1 == "#stats") {
      for (i=2; i<=NF; ++i) {
        _len = split($i, args, " ")
        if (args[1] == "columns") {  # Set default columns
          for (j=2; j<=_len; ++j) {
            stats[args[j]] = 1
          }
        } else {
          stats[args[1]] = args[2]
        }
      }
    # Set fan_points["stats name"] = "fan point value"
    } else if ($1 == "#fpts") {
      for (i=1; i<=NF; ++i) {
        split($i, args, "=")
        fan_points[args[1]] = args[2]
      }
    }
  }
}



### parse the command line arguments
function parse_args(   i) {
  for (i=1; i < ARGC - 1; ++i) {

    # Exit if args are not in the form category=value
    if ( ARGV[i] !~ /[a-z]+=[a-zA-Z0-9]+/ ) {
      print "!!! Error: Invalid argument ->", ARGV[i]
      print "\t-- Arguments must be of the form -> stat=value"
      status = -1
      exit  # This exit just moves program to END
    
    # Put all the conditions and their values into an array if they are valid
    # stat conditions. If a stat is not valid it will be ignored and
    # a notification made.
    } else {
      # arg[1] is stat name, arg[2] is value
      split(ARGV[i], args, "=")
      if ( columns[args[1]] ) {
        conditions[args[1]] = args[2]
        ++LEN_COND
      } else
        printf("!!! Ignored \"%s\" it is not a valid stat !!!\n", args[1])
    }
  }
  if ( LEN_COND == 0 ) {
    print ""
    print "!!! Error: No valid records entered. !!!"
    print "Exiting... "
    status = -1
    exit
  }
}



### Print the stat conditions
function print_conditions(   cat) {
  printf("-- Conditions: ")
  for ( cat in conditions ) {
    if ( cat == "player" || cat == "team" || cat == "pos" )
      printf("%s=%s", toupper(cat), toupper(conditions[cat]))
    else if ( cat == "age" )
      printf("%s<=%s", toupper(cat), toupper(conditions[cat]))
    else
      printf("%s>=%s, ", toupper(cat), toupper(conditions[cat]))
  }
  print "\n"
}



### Check if a record satisfies the stat conditions
function has_stats(   _show, cat) {
  _show = 1
  for ( cat in conditions ) {
    if ( cat == "player" || cat == "pos" || cat == "team" ) {
      if ( tolower($columns[cat]) !~ conditions[cat] )
        _show = 0
    } else if ( cat == "age" ) {
      if (  $columns[cat] > conditions[cat] )
        _show = 0
    } else if ( $columns[cat] < conditions[cat] ) {
      _show = 0
    } # could add year condition to make it only == year instead of >= year
  }
  return _show
}


### Print column headers
function print_headers() {
  printf("%-22s", "Player ")
  if ( stats["show"] ) {
    header_helper(stats)
  } else {
    header_helper(conditions)
  }
  print "Year"
}



### header helper -> uses globals
function header_helper(conditions,   i) {
  for ( i=2; i<LEN_COLS; ++i ) {
    if ( conditions[column_names[i]] )
      printf( "%-5s", toupper(column_names[i]) )
  }
}



### print all the records
function print_records(   i) {
  print "-----------------------------------------------------------------------"
  for ( i=1; i<=LEN_RECS; ++i) {
    # Print the record with default stats or only given condition stats
    if ( stats["show"] ) {
      print_record( records[i], stats )
    } else {
      print_record( records[i], conditions )
    }
    
    # Print line seperation after each 10 records for easier reading
    if ( i % 10 == 0 )
      printf("----------------  %s  -------------------------------------------------\n", i)
  }
  if (LEN_RECS % 10 != 0)
    printf("----------------  %s  -------------------------------------------------\n", LEN_RECS)
}



### print a record
function print_record(record, list,   _len, i) {
  _len = split(record, args, ",")
  printf( "%-22s", args[1] )
  for ( i=2; i<=_len; ++i ) {
    if ( list[column_names[i]] )
      printf( "%-5s", args[i] )
  }
  print args[columns["year"]]
}



### Print a list of players that satisfied the condition more than once
function print_multiples() {
  print ""
  print "-- Players with multiple seasons --"
  for ( player in multiples ) {
    if ( multiples[player] ~ /[0-9]+, [0-9]+/ )
      printf("%-22s %s\n", player, multiples[player])
  }
}



# calulates fan points using values in config. Uses $ operator so call during
# the parsing of a record not during the evaluation of the records array
function calc_fpts(   _total) {
  for ( stat in fan_points ) {
    if ( columns[stat] < 0 )
      print "!!! Error in config: #fpts \"" stat "\" is not a valid stat !!!"
    else
      _total += $columns[stat] * fan_points[stat]
  }
  return int(_total)
}



# Shell sort using compare function below. Sorts in non-increasing order
function sort_records(list, len, col_num,   h, i, j, check) {
  h = 1
  while (h < len) {
    h = (h * 3) + 1
  }
  
  while (h >= 1) {
    for (i=h+1; i<=len; ++i) {
      temp = list[i]
      j = i
      while (j>h && compare(temp, list[j-h], col_num) ) {
        list[j] = list[j-h]
        j -= h
      }
      list[j] = temp
    }
    h = (h - 1) / 3
  }
}

# compare records
function compare(rec1, rec2, col_num) {
  split(rec1, r1, ",")
  split(rec2, r2, ",")
  if ( r1[col_num] > r2[col_num] )
    return 1
  else
    return 0
}
