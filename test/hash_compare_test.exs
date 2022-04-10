defmodule HashCompareTest do
  use ExUnit.Case

  # It seems a bit redundant to do the same tests below that are also done in the doctests.
  # But I'm not sure what the preferred practices around this are just yet, keeping both for now.
  doctest HashCompare
  
  test "simple identical hashes are equal on shallow compare" do
    assert %{
      "foo" => {:same, "bar"}
    } == HashCompare.compare(
      %{"foo" => "bar"},
      %{"foo" => "bar"},
      false)
  end

  test "simple identical hashes are equal on deep compare" do
    assert %{
      "foo" => {:same, "bar"}
    } == HashCompare.compare(
      %{"foo" => "bar"},
      %{"foo" => "bar"},
      true)
  end
  
  test "simple hash with left-unique values on shallow compare" do
    assert %{
      "foo" => {:left_only, "bar"}
    } == HashCompare.compare(
      %{"foo" => "bar"},
      %{},
      false)
  end

  test "simple hash with left-unique values on deep compare" do
    assert %{
      "foo" => {:left_only, "bar"}
    } == HashCompare.compare(
      %{"foo" => "bar"},
      %{},
      true)
  end
  
  test "simple hash with right-unique values on shallow compare" do
    assert %{
      "foo" => {:right_only, "bar"}
    } == HashCompare.compare(
      %{},
      %{"foo" => "bar"},
      false)
  end
  
  test "simple hash with right-unique values on deep compare" do
    assert %{
      "foo" => {:right_only, "bar"}
    } == HashCompare.compare(
      %{},
      %{"foo" => "bar"},
      true)
  end
  
  test "complex hash with identical sub-maps on shallow compare" do
    both = %{
      "foo" => %{
        "a" => "b",
        1 => 2,
        :blah => 37.5
      }
    }
    
    result = %{
      "foo" => {:same, %{
        1 => 2,
        :blah => 37.5,
        "a" => "b"
      }}
    }
    
    assert result == HashCompare.compare(both, both, false)
  end

  test "complex hash with identical sub-maps on deep compare" do
    both = %{
      "foo" => %{
        "a" => "b",
        1 => 2,
        :blah => 37.5
      }
    }
    
    result = %{
      "foo" => {:sub_map,
       %{
         1 => {:same, 2},
         :blah => {:same, 37.5},
         "a" => {:same, "b"}
       }}
    }
    
    assert result == HashCompare.compare(both, both, true)
  end
  
  test "complex hash with left-unique entries in sub-map on shallow compare" do
    right = %{
      "a" => "b",
      "sub map" => %{
        :lunch => "undecided",
        "answer" => 42,
        "change" => "original value"
      },
      :list => ["foo", 42]
    }

    left = put_in(right["sub map"]["change"], "modified value!")

    result = %{
      "a" => {:same, "b"},
      "sub map" => {:different,
       %{
         left: %{
           :lunch => "undecided",
           "answer" => 42,
           "change" => "modified value!"
         },
         right: %{
           :lunch => "undecided",
           "answer" => 42,
           "change" => "original value"
         }
       }},
      :list => {:same, ["foo", 42]}
    } 
    
    assert result == HashCompare.compare(left, right, false)
  end

  test "complex hash with left-unique entries in sub-map on deep compare" do
    right = %{
      "a" => "b",
      "sub map" => %{
        :lunch => "undecided",
        "answer" => 42,
        "change" => "original value"
      },
      :list => ["foo", 42]
    }

    left = put_in(right["sub map"]["change"], "modified value!")
    
    result = %{
      "a" => {:same, "b"},
      "sub map" => {:sub_map,
       %{
         :lunch => {:same, "undecided"},
         "answer" => {:same, 42},
         "change" => {:different,
          %{
            left: "modified value!",
            right: "original value"
          }}
       }},
      :list => {:same, ["foo", 42]}
    }
    
    assert result == HashCompare.compare(left, right, true)
  end
  
  test "repeatedly nested map on shallow compare" do
    right = %{
      :a => %{
        "b" => %{
          3 => %{
            42.0 => %{
              "really deep" => :original
            }
          }
        }
      }
    }
    
    left = put_in(right[:a]["b"][3][42.0]["really deep"], "modified!")
    
    result = %{
      a: {:different, %{
        left: %{
          "b" => %{
            3 => %{42.0 => %{"really deep" => "modified!"}}
          }
        },
        right: %{
          "b" => %{
            3 => %{42.0 => %{"really deep" => :original}}
          }
        }
      }}
    }

    assert result == HashCompare.compare(left, right, false)
  end

  test "repeatedly nested map on deep compare" do
    right = %{
      :a => %{
        "b" => %{
          3 => %{
            42.0 => %{
              "really deep" => :original
            }
          }
        }
      }
    }
    
    left = put_in(right[:a]["b"][3][42.0]["really deep"], "modified!")
    
    result = %{
      a: {:sub_map,
        %{"b" => {:sub_map,
            %{3 => {:sub_map,
                %{42.0 => {:sub_map,
                    %{"really deep" => {:different,
                        %{left: "modified!", right: :original}}  
                    }}
                }}
            }}
        }}
    }
    assert result == HashCompare.compare(left, right, true)
  end
end
