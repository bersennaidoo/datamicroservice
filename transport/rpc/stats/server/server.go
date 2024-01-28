package server

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/jmoiron/sqlx"
	"github.com/sony/sonyflake"

	model "github.com/bersennaidoo/microdataservice/domain/models/stats"
	"github.com/bersennaidoo/microdataservice/transport/rpc/stats"
)

type Server struct {
	db        *sqlx.DB
	sonyflake *sonyflake.Sonyflake
}

var _ stats.StatsService = &Server{}

func (svc *Server) Push(ctx context.Context, r *stats.PushRequest) (*stats.PushResponse, error) {
	validate := func() error {
		if r.Property == "" {
			return errors.New("missing property")
		}
		if r.Property != "news" {
			return errors.New("invalid property")
		}
		if r.Id < 1 {
			return errors.New("missing id")
		}
		if r.Section < 1 {
			return errors.New("missing section")
		}
		return nil
	}
	if err := validate(); err != nil {
		return nil, err
	}

	var err error
	row := model.Incoming{}

	row.ID, err = svc.sonyflake.NextID()
	if err != nil {
		return nil, err
	}

	row.Property = r.Property
	row.PropertySection = r.Section

	row.PropertyID = r.Id
	if remoteIP, ok := ctx.Value("ip.address").(string); ok {
		row.RemoteIP = remoteIP
	}
	row.SetStamp(time.Now())

	fields := strings.Join(model.IncomingFields, ",")
	named := ":" + strings.Join(model.IncomingFields, ",:")

	query := fmt.Sprintf("insert into %s (%s) values (%s)", model.IncomingTable, fields, named)

	_, err = svc.db.NamedExecContext(ctx, query, row)

	return new(stats.PushResponse), err
}
